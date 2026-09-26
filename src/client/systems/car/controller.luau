const Workspace = game:GetService "Workspace"

const jecs = require "@game/ReplicatedStorage/packages/jecs"
const ct = require "@game/ReplicatedStorage/shared/components"
const simulation = require "@game/ReplicatedStorage/shared/ecs/simulation"
const presets = require "@game/ReplicatedStorage/shared/presets/car"
const inputs = require "../../inputs"
const force = require "@game/ReplicatedStorage/shared/utils/force"
const gizmos = require "@game/ReplicatedStorage/shared/utils/gizmos"
const action = require "@game/ReplicatedStorage/shared/utils/input/action"
const carUtil = require "../../utils/car"

const pair = jecs.pair
const ChildOf = jecs.ChildOf

const CANCEL_Y = Vector3.new(1, 0, 1)

const function calculateSpringForce(
    spring: presets.WheelSpring,
    rawLength: number,
    previousLength: number,
    dt: number
): (number, number)
    const minLength = spring.rest - spring.travel
    const maxLength = spring.rest + spring.travel

    const length = math.clamp(rawLength - spring.radius, minLength, maxLength)

    const displacement = spring.rest - length
    const stiffnessForce = spring.stiffness * displacement

    const velocity = (previousLength - length) / dt
    const dampingForce = spring.damping * velocity

    return (stiffnessForce + dampingForce), length
end

const function calculateDrivingForce(preset: presets.CarPreset, longVelocity: number, input: Vector2): number
    const longVelocityDir = math.sign(longVelocity)

    const longInput = input.Y
    const longInputDir = math.sign(longInput)

    const acceleration = preset.acceleration
    const curve = preset.curve

    local drivingForce = 0

    if longInput == 0 and math.abs(longVelocity) > 0.25 then
        drivingForce = -longVelocityDir * acceleration.coasting
    elseif longInput ~= 0 then
        if longInputDir == longVelocityDir or longVelocityDir == 0 then
            -- at the moment reverse speed is the same as forward speed, should change
            const throttle = curve.throttle:evaluate(math.abs(longVelocity)) * acceleration.throttle
            drivingForce = throttle * longInputDir
        else
            drivingForce = -longVelocityDir * acceleration.braking
        end
    end

    return drivingForce
end

const function calculateFrictionForce(preset: presets.CarPreset, longVelocity: number, latVelocity: number): number
    const curve = preset.curve

    const ratio = latVelocity / (latVelocity + longVelocity)
    const slideFriction = curve.friction:evaluate(ratio)

    return slideFriction
end

const function system(world: jecs.World)
    const car = carUtil.get()
    if not car then
        return
    end
    const model = carUtil.model(car)
    if not model then
        return
    end

    const preset = carUtil.preset(car)
    const params = carUtil.params(car)
    const hitbox = model.Hitbox

    const transform = hitbox.CFrame
    const look = transform.LookVector
    const right = transform.RightVector

    const velocity = hitbox.AssemblyLinearVelocity
    const longVelocity = velocity:Dot(look)
    const latVelocity = velocity:Dot(right)

    const dt = simulation:getDeltaTime(Enum.StepFrequency.Hz60)

    const _, state = action(inputs.movement)
    const input = state.input2D

    for id, name, offset, previousLength, spring in
        world:query(ct.Name, ct.Position, ct.Length, ct.WheelSpring):with(pair(ChildOf, car))
    do
        const position = transform * offset
        -- this relies on ensuring all other non-hitbox parts are massless
        const comPosition = transform * (offset * CANCEL_Y)

        const rayDirection = -transform.UpVector
        const rayDistance = spring.rest + spring.radius
        const ray = Workspace:Raycast(position, rayDirection * rayDistance, params)

        gizmos:DrawRaycast(position, rayDirection, ray :: RaycastResult)
        if ray then
            const springForce, length = calculateSpringForce(spring, ray.Distance, previousLength, dt)
            const suspensionForce = ray.Normal * springForce
            force.add(`{name}-suspension`, hitbox, suspensionForce, ray.Position)
            world:set(id, ct.Length, length)

            const drivingForce = look * calculateDrivingForce(preset, longVelocity, input)
            const frictionForce = right * -latVelocity * calculateFrictionForce(preset, longVelocity, latVelocity)
            force.add(`{name}-com`, hitbox, drivingForce + frictionForce, comPosition, true)
        else
            world:set(id, ct.Length, spring.rest)
        end
    end

    --     if grounded then
    --         const com = hitbox.AssemblyCenterOfMass
    --
    --         const drivingForce = calculateDrivingForce(preset, transform, hitbox.AssemblyLinearVelocity, input)
    --
    --         force.add(car, hitbox, drivingForce, com, true)
    --     end
end

return {
    name = "car/controller",
    system = system,
    phase = simulation.Phases.Simulation60Hz,
}

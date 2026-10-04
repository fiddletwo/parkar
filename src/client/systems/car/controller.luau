const Workspace = game:GetService "Workspace"

const jecs = require "@game/ReplicatedStorage/packages/jecs"
const ct = require "@game/ReplicatedStorage/shared/components"
const simulation = require "@game/ReplicatedStorage/shared/ecs/simulation"
const presets = require "@game/ReplicatedStorage/shared/presets/car"
const inputs = require "../../inputs"
const force = require "@game/ReplicatedStorage/shared/utils/force"
const action = require "@game/ReplicatedStorage/shared/utils/input/action"
const vector3Util = require "@game/ReplicatedStorage/shared/utils/vector3_util"
const sources = require "../../ui/sources"
const carUtil = require "../../utils/car"

const pair = jecs.pair
const ChildOf = jecs.ChildOf

const function calculateSpringForce(
    spring: presets.WheelSpring,
    rawLength: number,
    previousLength: number,
    dt: number
): (number, number)
    const length = rawLength - spring.radius

    const displacement = spring.rest - length
    const stiffnessForce = spring.stiffness * displacement

    const velocity = (previousLength - length) / dt
    const dampingForce = spring.damping * velocity

    return (stiffnessForce + dampingForce), length
end

const function calculateDrivingForce(
    preset: presets.CarPreset,
    longVelocity: number,
    longInput: number,
    boosting: boolean?
): number
    const longVelocityDir = math.sign(longVelocity)
    const longInputDir = math.sign(longInput)

    const acceleration = preset.acceleration
    const limits = preset.limits
    const curve = preset.curve

    local drivingForce = 0

    if longInput == 0 then
        -- WARNING: this might cause issues not ignoring coasting acceleration when really slow
        drivingForce = math.abs(longVelocity) < 0.25 and -longVelocity or -longVelocityDir * acceleration.coasting
    elseif longInput ~= 0 then
        if longInputDir == longVelocityDir or longVelocityDir == 0 then
            const throttle = curve.throttle:evaluate(math.abs(longVelocity) / limits.throttle)
                * (longInput >= 0 and acceleration.throttle or acceleration.reverse)
            drivingForce = throttle * longInputDir
        else
            drivingForce = -longVelocityDir * acceleration.braking
        end
    end

    return drivingForce
end

const function getSlipAngleRatio(latVelocity: number, longVelocity: number): number
    const slipAngleRad = math.atan(latVelocity / math.max(math.abs(longVelocity), 1))
    return math.abs(slipAngleRad / (math.pi / 2))
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
    const hitboxTransform = hitbox.CFrame
    const hitboxLinearVel = hitbox.AssemblyLinearVelocity
    const hitboxLongVelocity = hitboxLinearVel:Dot(hitboxTransform.LookVector)

    const dt = simulation:getDeltaTime(Enum.StepFrequency.Hz60)

    const _, moveState = action(inputs.movement)
    const input = moveState.input2D

    const _, boostState, boostReleased = action(inputs.boost)
    const boosting = boostState.held

    const limits = preset.limits
    const acceleration = preset.acceleration

    local wheelsGrounded = 0

    -- ackermann steering
    const wheelbase = math.abs(preset.wheels.fl.Z - preset.wheels.rl.Z)
    const track = math.abs(preset.wheels.rl.X - preset.wheels.rr.X)

    const innerAngle = math.deg(math.atan(wheelbase / (preset.turnRadius + track / 2))) * input.X
    const outerAngle = math.deg(math.atan(wheelbase / (preset.turnRadius - track / 2))) * input.X

    for id, name, spring, offset, previousLength, latFriction in
        world:query(ct.Name, ct.WheelSpring, ct.Position, ct.Length, ct.Friction):with(pair(ChildOf, car))
    do
        -- this relies on ensuring all other non-hitbox parts are massless
        local comTransform = hitboxTransform * CFrame.new(offset * vector3Util.CANCEL_Y)
        const comPosition = comTransform.Position

        const steerable = name == "fl" or name == "fr"
        if steerable then
            local steerAngle = 0
            if input.X > 0 then
                if name == "fl" then
                    steerAngle = innerAngle
                elseif name == "fr" then
                    steerAngle = outerAngle
                end
            elseif input.X < 0 then
                if name == "fl" then
                    steerAngle = outerAngle
                elseif name == "fr" then
                    steerAngle = innerAngle
                end
            end

            comTransform *= CFrame.Angles(0, math.rad(-steerAngle), 0)
        end

        const springTransform = hitboxTransform * CFrame.new(offset)
        const springOrigin = springTransform.Position

        const rayDirection = -springTransform.UpVector
        const rayDistance = spring.rest + spring.radius
        const ray = Workspace:Raycast(springOrigin, rayDirection * rayDistance, params)

        if ray then
            wheelsGrounded += 1

            const look = vector3Util.projectOnPlane(comTransform.LookVector, ray.Normal).Unit
            const right = vector3Util.projectOnPlane(comTransform.RightVector, ray.Normal).Unit

            const velocity = comTransform:VectorToObjectSpace(hitbox:GetVelocityAtPosition(comPosition))
            const longVelocity = -velocity.Z
            const latVelocity = velocity.X

            const springForce, length = calculateSpringForce(spring, ray.Distance, previousLength, dt)
            const suspensionForce = ray.Normal * springForce
            force.add(hitbox, suspensionForce, ray.Position)
            world:set(id, ct.Length, length)

            const drivingForce = look * calculateDrivingForce(preset, hitboxLongVelocity, boosting and 1 or input.Y)
            force.add(hitbox, drivingForce, comPosition, force.Mode.Acceleration)

            const curve = preset.curve
            const relaxationLength = 0.055
            const slipAngle = getSlipAngleRatio(latVelocity, longVelocity)

            const latSlipTarget = curve.friction:evaluate(slipAngle) * -math.sign(latVelocity)
            const latCoefficient = math.clamp(math.abs(latVelocity) / relaxationLength * dt, 0, 1)

            -- integrate towards target friction value
            latFriction += (latSlipTarget - latFriction) * latCoefficient
            world:set(id, ct.Friction, latFriction)

            const frictionForce = right * latFriction * math.max(springForce, 0)
            force.add(hitbox, frictionForce, comPosition)
        else
            world:set(id, ct.Length, spring.rest)
        end
    end

    local boostForce: number
    if wheelsGrounded >= 3 then
        boostForce = acceleration.groundBoost

        if not world:has(car, pair(ct.Timer, ct.Debounce)) and action(inputs.jump) then
            force.add(hitbox, hitboxTransform.UpVector * 45, hitbox.Position, force.Mode.VelocityChange)
            world:set(car, pair(ct.Timer, ct.Debounce), {
                start = os.clock(),
                duration = 0.3,
                repeats = false,
            })
        end
    else
        boostForce = acceleration.airBoost

        const up = hitboxTransform.UpVector
        const look = hitboxTransform.LookVector
        const right = hitboxTransform.RightVector

        const _, rollState = action(inputs.roll)
        const rollInput = rollState.input1D

        const hitboxAngularVel = hitbox.AssemblyAngularVelocity
        const yawVel = hitboxAngularVel:Dot(up)
        const rollVel = hitboxAngularVel:Dot(look)
        const pitchVel = hitboxAngularVel:Dot(right)

        const drag = acceleration.drag * yawVel * up * (1 - math.abs(input.X))
            + acceleration.drag * rollVel * look * (1 - math.abs(input.Y))
            + acceleration.drag * pitchVel * right * (1 - math.abs(rollInput))

        const torque = acceleration.yaw * -input.X * up
            + acceleration.roll * rollInput * look
            + acceleration.pitch * -input.Y * right

        force.torque(hitbox, torque - drag, force.Mode.Acceleration)
    end

    const boost = world:get(car, ct.Boost) or 100
    if boosting then
        if boost > 0 then
            const targetBoost = math.max(boost - 40 * dt, 0)
            world:set(car, ct.Boost, targetBoost)
            force.add(hitbox, hitboxTransform.LookVector * boostForce, hitbox.Position, force.Mode.Acceleration)

            sources.car.boost(targetBoost)
        end
    elseif boostReleased then
        world:set(car, pair(ct.Timer, ct.Boost), {
            start = os.clock(),
            duration = 2,
            repeats = false,
        })
    elseif not world:has(car, pair(ct.Timer, ct.Boost)) then
        const targetBoost = math.min(boost + 10 * dt, 100)
        world:set(car, ct.Boost, targetBoost)

        sources.car.boost(targetBoost)
    end

    -- limit velocity
    hitbox.AssemblyLinearVelocity = hitboxLinearVel.Unit * math.min(hitboxLinearVel.Magnitude, limits.max)
end

return {
    name = "car/controller",
    system = system,
    phase = simulation.Phases.Simulation60Hz,
}

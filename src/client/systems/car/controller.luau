const Workspace = game:GetService "Workspace"

const jecs = require "@game/ReplicatedStorage/packages/jecs"
const ct = require "@game/ReplicatedStorage/shared/components"
const simulation = require "@game/ReplicatedStorage/shared/ecs/simulation"
const force = require "@game/ReplicatedStorage/shared/utils/force"
const gizmos = require "@game/ReplicatedStorage/shared/utils/gizmos"
const carUtil = require "../../utils/car"

const pair = jecs.pair
const ChildOf = jecs.ChildOf

const function system(world: jecs.World)
    const car = carUtil.get()
    if not car then
        return
    end
    const model = carUtil.model(car)
    if not model then
        return
    end

    const params = carUtil.params(car)
    const hitbox = model.Hitbox
    const transform = hitbox.CFrame

    const dt = simulation:getDeltaTime(Enum.StepFrequency.Hz60)

    for id, offset, previousLength, spring in
        world:query(ct.Position, ct.Length, ct.WheelSpring):with(pair(ChildOf, car))
    do
        const position = transform * offset
        const rayDirection = -transform.UpVector
        const rayDistance = spring.rest + spring.radius
        const ray = Workspace:Raycast(position, rayDirection * rayDistance, params)

        gizmos:DrawRaycast(position, rayDirection, ray :: RaycastResult)

        if ray then
            const length = ray.Distance - spring.radius

            const displacement = spring.rest - length
            const stiffnessForce = spring.stiffness * displacement

            const velocity = (previousLength - length) / dt
            const dampingForce = spring.damping * velocity

            const netForce = ray.Normal * (stiffnessForce + dampingForce)
            force.add(id, hitbox, netForce, ray.Position)

            world:set(id, ct.Length, length)
        else
            world:set(id, ct.Length, spring.rest)
        end
    end
end

return {
    name = "car/controller",
    system = system,
    phase = simulation.Phases.Simulation60Hz,
}

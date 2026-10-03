const Workspace = game:GetService "Workspace"

const jecs = require "@game/ReplicatedStorage/packages/jecs"
const planck_runservice = require "@game/ReplicatedStorage/packages/planck-runservice"
const ct = require "@game/ReplicatedStorage/shared/components"
const presets = require "@game/ReplicatedStorage/shared/presets/car"
const carModel = require "@game/ReplicatedStorage/shared/utils/car/model"

const pair = jecs.pair
const ChildOf = jecs.ChildOf
const Wildcard = jecs.Wildcard

const function createWheelPart(radius: number, width: number): Part
    const part = Instance.new "Part"
    part.Name = "Anchor"
    part.Color = Color3.fromRGB(17, 17, 17)
    part.Shape = Enum.PartType.Cylinder
    part.Material = Enum.Material.SmoothPlastic
    part.EnableFluidForces = false
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.AudioCanCollide = false
    part.CanQuery = false
    part.Massless = true
    part.Size = Vector3.new(width, radius * 2, radius * 2)

    return part
end

const params = RaycastParams.new()

const function system(world: jecs.World)
    const needsWheel =
        world:query(ct.Name, ct.WheelSpring):with(ct.Wheel, pair(ChildOf, Wildcard)):without(ct.Renderable):cached()

    const wheels =
        world:query(ct.WheelSpring, ct.Position, ct.Renderable):with(ct.Wheel, pair(ChildOf, Wildcard)):cached()

    return function()
        for id, name, spring in needsWheel do
            const parent = world:parent(id) :: jecs.Entity
            const car, presetName = world:get(parent, ct.Renderable, ct.CarPreset)

            if car and presetName then
                const preset = presets[presetName]

                const wheel = Instance.new "Model"
                wheel.Name = name

                const part = createWheelPart(spring.radius, preset.wheelWidth)
                part.Parent = wheel

                wheel.Parent = Workspace.RaycastIgnore
                world:set(id, ct.Renderable, wheel)
            end
        end

        const partList: { BasePart } = {}
        const transformList: { CFrame } = {}

        for id, spring, offset, wheel: Model & { Anchor: Part } in wheels do
            const parent = world:parent(id) :: jecs.Entity
            const car: carModel.Car? = world:get(parent, ct.Renderable)

            if not car then
                continue
            end

            const hitbox = car.Hitbox
            const hitboxTransform = hitbox.CFrame

            params.ExcludeInstances = { Workspace.RaycastIgnore, car }

            const springTransform = hitboxTransform * CFrame.new(offset)
            const springOrigin = springTransform.Position

            const rayDirection = -springTransform.UpVector
            const rayDistance = spring.rest + spring.radius
            const ray = Workspace:Raycast(springOrigin, rayDirection * rayDistance, params)

            if ray then
                const springLength = ray.Distance - spring.radius
                transformList[#transformList + 1] = springTransform + rayDirection * springLength
            else
                transformList[#transformList + 1] = springTransform + rayDirection * spring.rest
            end

            partList[#partList + 1] = wheel.Anchor
        end

        Workspace:BulkMoveTo(partList, transformList, Enum.BulkMoveMode.FireCFrameChanged)
    end
end

return {
    name = "car/render",
    system = system,
    phase = planck_runservice.Phases.Update,
}

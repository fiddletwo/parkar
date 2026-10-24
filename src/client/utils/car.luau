const Players = game:GetService "Players"
const Workspace = game:GetService "Workspace"

const carModel = require "@game/ReplicatedStorage/shared/utils/car/model"
const ct = require "@game/ReplicatedStorage/shared/components"
const jecs = require "@game/ReplicatedStorage/packages/jecs"
const jecs_utils = require "@game/ReplicatedStorage/packages/jecs-utils"
const presets = require "@game/ReplicatedStorage/shared/presets/car"
const world = require "@game/ReplicatedStorage/shared/world"

const ref = jecs_utils.ref

const function getLocalCar(): jecs.Entity?
    const player = ref(Players.LocalPlayer)

    return world:target(player, ct.Car) :: jecs.Entity?
end

const function getPreset(id: jecs.Entity): presets.CarPreset
    return presets[world:get(id, ct.CarPreset) :: any]
end

const function getLocalCarModel(id: jecs.Entity?): carModel.Car?
    const car = id or getLocalCar()

    if car then
        const model = world:get(car, ct.Renderable)
        if model and model:FindFirstChild "Hitbox" then
            return model
        end
    end

    return nil
end

const function getRaycastParams(id: jecs.Entity): RaycastParams
    local params = world:get(id, ct.RaycastParams)
    if params then
        return params
    end

    params = RaycastParams.new()
    params.ExcludeInstances = { Workspace.RaycastIgnore, Workspace.Cars }
    return params
end

return {
    get = getLocalCar,
    preset = getPreset,
    model = getLocalCarModel,
    params = getRaycastParams,
}

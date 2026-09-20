const Players = game:GetService "Players"

const jecs = require "@game/ReplicatedStorage/packages/jecs"
const jecs_utils = require "@game/ReplicatedStorage/packages/jecs-utils"
const ct = require "@game/ReplicatedStorage/shared/components"
const carModel = require "@game/ReplicatedStorage/shared/utils/car/model"
const world = require "@game/ReplicatedStorage/shared/world"

const ref = jecs_utils.ref

const function getLocalCar(): jecs.Entity?
    const player = ref(Players.LocalPlayer)

    return world:target(player, ct.Car) :: jecs.Entity?
end

const function getLocalCarModel(id: jecs.Entity?): carModel.Car?
    const car = id or getLocalCar()

    return car and world:get(car, ct.Renderable) or nil
end

return {
    get = getLocalCar,
    model = getLocalCarModel,
}

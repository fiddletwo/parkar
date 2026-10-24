const carUtil = require "../../utils/car"
const ct = require "@game/ReplicatedStorage/shared/components"
const jecs = require "@game/ReplicatedStorage/packages/jecs"
const planck_runservice = require "@game/ReplicatedStorage/packages/planck-runservice"
const sources = require "../../ui/sources"

local previousBoost = 100

const function system(world: jecs.World)
    const car = carUtil.get()
    if not car then
        sources.car.alive(false)
        return
    end

    if not sources.car.alive() then
        sources.car.alive(true)
    end

    const boost = world:get(car, ct.Boost) or 100
    if boost ~= previousBoost then
        sources.car.boost(boost)
    end

    previousBoost = boost
end

return {
    name = "car/update-states",
    system = system,
    phase = planck_runservice.Phases.PreRender,
}

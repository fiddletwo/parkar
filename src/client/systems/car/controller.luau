const jecs = require "@game/ReplicatedStorage/packages/jecs"
const simulation = require "@game/ReplicatedStorage/shared/ecs/simulation"

const function system(world: jecs.World)
    -- const model = carUtil.model()
end

return {
    name = "car/controller",
    system = system,
    phase = simulation.Phases.Simulation60Hz,
}

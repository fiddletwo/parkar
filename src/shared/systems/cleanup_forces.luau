const simulation = require "../ecs/simulation"
const force = require "../utils/force"

return {
    name = "cleanup-forces",
    system = force.cleanup,
    phase = simulation.Phases.Simulation60Hz,
}

const ct = require "@game/ReplicatedStorage/shared/components"
const jecs = require "@game/ReplicatedStorage/packages/jecs"
const jecs_utils = require "@game/ReplicatedStorage/packages/jecs-utils"
const network = require "../../network"
const planck_runservice = require "@game/ReplicatedStorage/packages/planck-runservice"

const ref = jecs_utils.ref

const function system(world: jecs.World)
    for _, player in network.Game.SendReady.iter() do
        const id = ref(player)
        world:add(id, ct.Ready)
    end
end

return {
    name = "player/ready",
    system = system,
    phase = planck_runservice.Phases.Update,
}

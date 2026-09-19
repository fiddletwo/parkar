const jecs = require "@game/ReplicatedStorage/packages/jecs"
const planck_runservice = require "@game/ReplicatedStorage/packages/planck-runservice"
const replicator = require "../../replicator"
const network = require "../../network"

const function system(world: jecs.World)
    for _, buf, variants in network.EntityReplication.SendReliable.iter() do
        replicator:apply_updates(buf, variants)
    end

    for _, buf, variants in network.EntityReplication.SendUnreliable.iter() do
        replicator:apply_unreliable(buf, variants)
    end
end

return {
    name = "replication/apply-updates",
    system = system,
    phase = planck_runservice.Phases.Update,
}

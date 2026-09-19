const jecs_utils = require "@game/ReplicatedStorage/packages/jecs-utils"
const planck_runservice = require "@game/ReplicatedStorage/packages/planck-runservice"
const network = require "../../network"
const replicator = require "../../replicator"

const interval = jecs_utils.interval

const reliableInterval = interval(1 / 20)
const unreliableInterval = interval(1 / 30)

const function system()
    if reliableInterval() then
        for player, buf, variants in replicator:collect_updates() do
            network.EntityReplication.SendReliable.fire(player, buf, variants)
        end
    end

    if unreliableInterval() then
        for player, buf, variants in replicator:collect_unreliable() do
            network.EntityReplication.SendUnreliable.fire(player, buf, variants)
        end
    end
end

return {
    name = "replication/send-updates",
    system = system,
    phase = planck_runservice.Phases.Update,
}

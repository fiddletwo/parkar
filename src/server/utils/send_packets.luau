const network = require "../network"
const replicator = require "../replicator"

const function sendPackets()
    network.EntityReplication.RequestInitialPackets.on(function(player)
        if replicator:is_player_ready(player) then
            return
        end
        replicator:mark_player_ready(player)

        return replicator:get_full(player)
    end)
end

return sendPackets

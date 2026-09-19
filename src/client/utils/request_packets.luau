const network = require "../network"
const replicator = require "../replicator"

const function requestPackets()
    const buf, variants = network.EntityReplication.RequestInitialPackets.invoke()
    if buf then
        replicator:apply_full(buf, variants)
    end
end

return requestPackets

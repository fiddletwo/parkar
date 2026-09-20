require "@game/ReplicatedStorage/shared/components"

const ReplicatedStorage = game:GetService "ReplicatedStorage"
const ServerScriptService = game:GetService "ServerScriptService"

const schedule = require "@game/ReplicatedStorage/shared/ecs/schedule"
const world = require "@game/ReplicatedStorage/shared/world"
const replicator = require "@self/replicator"
const sendPackets = require "@self/utils/send_packets"
const systems = ServerScriptService.server.systems
const sharedSystems = ReplicatedStorage.shared.systems

replicator:init()
-- stylua: ignore start
schedule(world,
    systems.replication.send_updates,

    sharedSystems.players.initialize,
    sharedSystems.players.added,
    sharedSystems.players.removed,

    systems.players.car
)
-- stylua: ignore end
sendPackets()

require "@game/ReplicatedStorage/shared/components"

const ReplicatedStorage = game:GetService "ReplicatedStorage"

const schedule = require "@game/ReplicatedStorage/shared/ecs/schedule"
const world = require "@game/ReplicatedStorage/shared/world"
const replicator = require "@self/replicator"
const requestPackets = require "@self/utils/request_packets"
const systems = script.systems
const sharedSystems = ReplicatedStorage.shared.systems

replicator:init()
-- stylua: ignore start
schedule(world,
    systems.replication.apply_updates,

    sharedSystems.players.initialize,
    sharedSystems.players.added,
    sharedSystems.players.removed,

    systems.camera.player,
    systems.camera.update
)
-- stylua: ignore end
requestPackets()

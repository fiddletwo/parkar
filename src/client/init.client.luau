require "@game/ReplicatedStorage/shared/components"
require "@self/inputs"

const ReplicatedStorage = game:GetService "ReplicatedStorage"

const replicator = require "@self/replicator"
const requestPackets = require "@self/utils/request_packets"
const schedule = require "@game/ReplicatedStorage/shared/ecs/schedule"
const world = require "@game/ReplicatedStorage/shared/world"
const systems = script.systems
const sharedSystems = ReplicatedStorage.shared.systems

replicator:init()
-- stylua: ignore start
schedule(world,
    systems.replication.apply_updates,

    systems.ui,

    sharedSystems.timer,

    sharedSystems.players.initialize,
    sharedSystems.players.added,
    sharedSystems.players.removed,

    systems.car.controller,
    systems.car.render,
    systems.car.update_stats,

    systems.camera.player,
    systems.camera.update,

    systems.game
)
-- stylua: ignore end
requestPackets()

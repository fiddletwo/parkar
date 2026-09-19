const Players = game:GetService "Players"
const RunService = game:GetService "RunService"

const jecs = require "@game/ReplicatedStorage/packages/jecs"
const planck_runservice = require "@game/ReplicatedStorage/packages/planck-runservice"
const replicator = require "@game/ReplicatedStorage/shared/ecs/replicator"
const ct = require "@game/ReplicatedStorage/shared/components"
const jecs_utils = require "@game/ReplicatedStorage/packages/jecs-utils"

const IS_SERVER = RunService:IsServer()

const collect = jecs_utils.collect
const ref = jecs_utils.ref

const collectPlayersJoined = collect(Players.PlayerAdded)

const function system(world: jecs.World)
    for _, player in collectPlayersJoined.iter() do
        const playerEntity = ref(player)
        world:set(playerEntity, ct.Player, player)

        if IS_SERVER then
            replicator.server:set_networked(playerEntity)
            replicator.server:set_custom(playerEntity, ct.Player)
            replicator.server:set_reliable(playerEntity, ct.Player)
        end
    end
end

return {
    name = "players/added",
    system = system,
    phase = planck_runservice.Phases.Update,
}

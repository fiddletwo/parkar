const Players = game:GetService "Players"

const jecs = require "@game/ReplicatedStorage/packages/jecs"
const planck_runservice = require "@game/ReplicatedStorage/packages/planck-runservice"
const jecs_utils = require "@game/ReplicatedStorage/packages/jecs-utils"

const collect = jecs_utils.collect
const ref = jecs_utils.ref

const collectPlayersLeft = collect(Players.PlayerRemoving)

const function system(world: jecs.World)
    for _, player in collectPlayersLeft.iter() do
        const playerEntity = ref.find(player)
        if playerEntity then
            world:delete(playerEntity)
            ref.delete(player)
        end
    end
end

return {
    name = "players/removed",
    system = system,
    phase = planck_runservice.Phases.Update,
}

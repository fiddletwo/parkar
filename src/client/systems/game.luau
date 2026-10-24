const ct = require "@game/ReplicatedStorage/shared/components"
const jecs = require "@game/ReplicatedStorage/packages/jecs"
const jecs_utils = require "@game/ReplicatedStorage/packages/jecs-utils"
const planck_runservice = require "@game/ReplicatedStorage/packages/planck-runservice"
const sources = require "../ui/sources"

const pair = jecs.pair
const monitor = jecs_utils.query_monitor

const function system(world: jecs.World)
    const collectPlayersAdded = monitor(world:query(pair(ct.Timestamp, ct.Round), pair(ct.Timestamp, ct.Countdown)))

    return function()
        for id in collectPlayersAdded.added() do
            const roundTime, countdownTime =
                world:get(id, pair(ct.Timestamp, ct.Round), pair(ct.Timestamp, ct.Countdown))

            if roundTime and countdownTime then
                sources.game.round(roundTime)
                sources.game.countdown(countdownTime)
            end
        end
    end
end

return {
    name = "game",
    system = system,
    phase = planck_runservice.Phases.Update,
}

const network = require "../network"
const planck_runservice = require "@game/ReplicatedStorage/packages/planck-runservice"
const sources = require "../ui/sources"

const function system()
    for _, round in network.Game.SendRoundInfo.iter() do
        sources.game.countdown(round.countdown)
        sources.game.round(round.round)
    end
end

return {
    name = "game",
    system = system,
    phase = planck_runservice.Phases.Update,
}

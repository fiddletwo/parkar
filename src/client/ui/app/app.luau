const Hud = require "./routes/hud"
const PlayerFail = require "./routes/player_fail"
const Round = require "./routes/round"
const Welcome = require "./routes/welcome"
const rem = require "../utils/rem"
const sources = require "../sources"
const vide = require "@game/ReplicatedStorage/packages/vide"

const create = vide.create
const show = vide.show

const function App()
    rem.useRem()

    return create "ScreenGui" {
        ResetOnSpawn = true,
        IgnoreGuiInset = true,

        show(sources.game.showWelcome, Welcome),
        show(sources.car.alive, Hud),
        Round(),
        PlayerFail(),
    }
end

return App

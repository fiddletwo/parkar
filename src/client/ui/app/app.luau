const Hud = require "./routes/hud"
const Round = require "./routes/round"
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

        show(sources.car.alive, Hud),
        Round(),
    }
end

return App

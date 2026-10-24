const Hud = require "./routes/hud"
const Round = require "./routes/round"
const rem = require "../utils/rem"
const vide = require "@game/ReplicatedStorage/packages/vide"
const create = vide.create

const function App()
    rem.useRem()

    return create "ScreenGui" {
        ResetOnSpawn = true,
        IgnoreGuiInset = true,

        Hud(),
        Round(),
    }
end

return App

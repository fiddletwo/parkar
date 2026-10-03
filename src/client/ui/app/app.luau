const vide = require "@game/ReplicatedStorage/packages/vide"
const Hud = require "./routes/hud"
const rem = require "../utils/rem"
const create = vide.create

const function App()
    rem.useRem()

    return create "ScreenGui" {
        ResetOnSpawn = true,
        IgnoreGuiInset = true,

        Hud(),
    }
end

return App

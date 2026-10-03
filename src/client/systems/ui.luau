const Players = game:GetService "Players"

const planck = require "@game/ReplicatedStorage/packages/planck"
const vide = require "@game/ReplicatedStorage/packages/vide"
const App = require "../ui/app/app"

const mount = vide.mount

const function system()
    mount(App, Players.LocalPlayer.PlayerGui)
end

return {
    name = "ui",
    system = system,
    phase = planck.Phase.PostStartup,
}

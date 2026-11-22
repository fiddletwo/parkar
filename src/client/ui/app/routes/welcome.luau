const RunService = game:GetService "RunService"

const action = require "@game/ReplicatedStorage/shared/utils/input/action"
const colors = require "../../styles/colors"
const fonts = require "../../styles/fonts"
const inputs = require "../../../inputs"
const network = require "../../../network"
const rem = require "../../utils/rem"
const sources = require "../../sources"
const vide = require "@game/ReplicatedStorage/packages/vide"

const create = vide.create
const effect = vide.effect
const cleanup = vide.cleanup

const function Welcome()
    effect(function()
        const connection = RunService.Heartbeat:Connect(function()
            if action(inputs.play) then
                sources.game.showWelcome(false)

                task.defer(function()
                    network.Game.SendReady.fire()
                end)
            end
        end)

        cleanup(connection)
    end)

    return create "Frame" {
        Size = UDim2.fromScale(1, 1),
        -- BackgroundTransparency = 0.4,
        BackgroundColor3 = colors.blackishGray,
        ZIndex = 100,

        create "TextLabel" {
            AnchorPoint = Vector2.new(0.5, 0),
            Size = rem.fromOffset(10, 5),
            Position = rem.fromUDim2(0.5, 0, 0, 8),
            BackgroundTransparency = 1,
            TextColor3 = colors.white,
            TextXAlignment = Enum.TextXAlignment.Center,
            Text = "Parkar",
            FontFace = fonts.rubik.bold,
            TextSize = rem(6),
        },

        create "TextLabel" {
            AnchorPoint = Vector2.new(0.5, 1),
            Size = rem.fromOffset(10, 5),
            Position = rem.fromUDim2(0.5, 0, 1, -8),
            BackgroundTransparency = 1,
            TextColor3 = colors.white,
            TextXAlignment = Enum.TextXAlignment.Center,
            Text = "Click to start playing",
            FontFace = fonts.rubik.regular,
            TextSize = rem(2),
        },
    }
end

return Welcome

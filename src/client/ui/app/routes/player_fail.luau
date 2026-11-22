const colors = require "../../styles/colors"
const fonts = require "../../styles/fonts"
const network = require "../../../network"
const rem = require "../../utils/rem"
const vide = require "@game/ReplicatedStorage/packages/vide"

const create = vide.create
const cleanup = vide.cleanup
const effect = vide.effect
const source = vide.source

const function PlayerFail()
    const showFailMessage = source(false)

    effect(function()
        const connection = network.Game.SendPlayerFail.on(function()
            showFailMessage(true)
            task.delay(5, function()
                showFailMessage(false)
            end)
        end)

        cleanup(connection)
    end)

    return create "TextLabel" {
        AnchorPoint = Vector2.new(0.5, 0),
        Size = rem.fromOffset(6, 4),
        Position = rem.fromUDim2(0.5, 0, 0.5, 14),
        BackgroundTransparency = 1,
        TextColor3 = colors.blackishGray,
        TextXAlignment = Enum.TextXAlignment.Center,
        Text = "You failed!",
        FontFace = fonts.rubik.bold,
        TextSize = rem(4),
        Visible = showFailMessage,

        create "UIStroke" {
            Color = colors.white,
            Thickness = rem(0.125),
        },
    }
end

return PlayerFail

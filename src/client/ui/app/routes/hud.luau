const vide = require "@game/ReplicatedStorage/packages/vide"
const Padding = require "../../components/padding"
const colors = require "../../styles/colors"
const fonts = require "../../styles/fonts"
const rem = require "../../utils/rem"
const Container = require "../../components/container"

const create = vide.create

const function Hud()
    return Container {
        Size = UDim2.fromScale(1, 1),

        Container {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.fromScale(0, 1),
            Size = rem.fromOffset(16, 3.25),
            ZIndex = 10,

            create "TextLabel" {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                FontFace = fonts.rubik.regular,
                RichText = true,
                Text = "<b>CTRL</b> Lock Camera",
                TextColor3 = colors.white,
                TextSize = rem(1.5),
                TextXAlignment = Enum.TextXAlignment.Left,

                Padding { Left = UDim.new(0, rem(2)()) },
            },
        },
    }
end

return Hud

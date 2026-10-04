const vide = require "@game/ReplicatedStorage/packages/vide"
const sources = require "../../sources"
const Padding = require "../../components/padding"
const colors = require "../../styles/colors"
const fonts = require "../../styles/fonts"
const rem = require "../../utils/rem"
const Container = require "../../components/container"

const create = vide.create

const function Hud()
    const boostRatio = function()
        return UDim2.fromScale(sources.car.boost() / 100, 1)
    end

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

                Padding { Left = rem.fromUDim(0, 2) },
            },
        },
        create "Frame" {
            AnchorPoint = Vector2.new(0.5, 1),
            Position = rem.fromUDim2(0.5, 0, 1, -1.5),
            Size = rem.fromOffset(30, 0.8),
            BackgroundColor3 = colors.blackishGray,
            ClipsDescendants = true,

            create "UICorner" {
                CornerRadius = UDim.new(1, 0),
            },
            create "UIStroke" {
                Color = colors.white,
                Thickness = rem(0.125),
            },
            create "Frame" {
                Size = boostRatio,
                BackgroundColor3 = Color3.fromHex "#E28039",

                create "UICorner" {
                    CornerRadius = UDim.new(1, 0),
                },
            },
        },
    }
end

return Hud

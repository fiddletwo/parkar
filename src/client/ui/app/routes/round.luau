const RunService = game:GetService "RunService"
const Workspace = game:GetService "Workspace"

const Container = require "../../components/container"
const colors = require "../../styles/colors"
const fonts = require "../../styles/fonts"
const rem = require "../../utils/rem"
const sources = require "../../sources"
const vide = require "@game/ReplicatedStorage/packages/vide"

const create = vide.create
const effect = vide.effect
const source = vide.source
const show = vide.show
const cleanup = vide.cleanup

const function Round()
    const countdownTime = source(0)
    const roundTime = source(0)

    const formattedCountdownTime = function()
        const timeLeft = countdownTime()
        const seconds = math.ceil(timeLeft)
        return `Round starts in {seconds} second{seconds > 1 and "s" or ""}`
    end
    const formattedRoundTime = function()
        const timeLeft = roundTime()
        const minutes = math.floor(timeLeft / 60)
        const seconds = math.floor(timeLeft % 60)
        return `{minutes}:{seconds}`
    end

    effect(function()
        const countdown = sources.game.countdown()
        const round = sources.game.round()

        const connection = RunService.Heartbeat:Connect(function()
            const now = Workspace:GetServerTimeNow()

            const countdownTimeLeft = math.max(0, countdown - now)
            countdownTime(countdownTimeLeft)

            if countdownTimeLeft == 0 then
                roundTime(math.max(0, round - now))
            end
        end)

        cleanup(connection)
    end)

    const CountdownTimer = function()
        return create "TextLabel" {
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.fromScale(0.5, 0),
            Size = rem.fromOffset(18.75, 3.75),
            BackgroundTransparency = 1,
            FontFace = fonts.rubik.bold,
            Text = formattedCountdownTime,
            TextColor3 = colors.white,
            TextSize = rem(1.5),

            create "UIStroke" {
                Color = colors.blackishGray,
                Thickness = rem(0.125),
            },
        }
    end

    const RoundTimer = function()
        return create "TextLabel" {
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.fromScale(0.5, 0),
            Size = rem.fromOffset(18.75, 3.75),
            BackgroundTransparency = 1,
            FontFace = fonts.rubik.bold,
            Text = formattedRoundTime,
            TextColor3 = colors.white,
            TextSize = rem(2.5),

            create "UIStroke" {
                Color = colors.blackishGray,
                Thickness = rem(0.125),
            },
        }
    end

    return Container {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = rem.fromUDim2(0.5, 0, 0, 5),
        Size = rem.fromOffset(30, 15),

        show(function()
            return countdownTime() > 0
        end, CountdownTimer),
        show(function()
            return countdownTime() == 0
        end, RoundTimer),
    }
end

return Round

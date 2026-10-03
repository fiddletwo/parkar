const Workspace = game:GetService "Workspace"

const vide = require "@game/ReplicatedStorage/packages/vide"

const source = vide.source
const cleanup = vide.cleanup

const BASE_RESOLUTION = Vector2.new(1920, 1080)
const BASE_REM = 16
const MIN_REM = 10
const DOMINANT_AXIS = 0.5

const _rem = source(BASE_REM)

const function rem(scale: number?): () -> number
    return function()
        return _rem() * (scale or 1)
    end
end

const function fromOffset(x: number, y: number): () -> UDim2
    return function()
        return UDim2.fromOffset(rem(x)(), rem(y)())
    end
end

const function useRem()
    const camera = Workspace.CurrentCamera

    const function update()
        const size = camera.ViewportSize

        const width = math.log(size.X / BASE_RESOLUTION.X, 2)
        const height = math.log(size.Y / BASE_RESOLUTION.Y, 2)
        const centered = width + (height - width) * DOMINANT_AXIS

        _rem(math.max(BASE_REM * 2 ^ centered, MIN_REM))
    end

    update()

    cleanup(camera:GetPropertyChangedSignal("ViewportSize"):Connect(update))
end

return setmetatable({
    useRem = useRem,
    fromOffset = fromOffset,
}, {
    __call = function(_, scale: number?): () -> number
        return rem(scale)
    end,
})

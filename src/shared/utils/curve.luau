type LinearCurveKey = {
    x: number,
    y: number,
}

const Curve = {}
Curve.__index = Curve

export type Curve = setmetatable<{ _instance: FloatCurve }, typeof(Curve)>

function Curve.new(instance: FloatCurve): Curve
    const self = {}
    self._instance = instance

    return setmetatable(self, Curve)
end

function Curve:evaluate(time: number): number
    return self._instance:GetValueAtTime(time) :: number
end

const function createLinearCurve(keys: { LinearCurveKey }): Curve
    const curve = Instance.new "FloatCurve"

    const _keys: { FloatCurveKey } = {}
    for _, info in keys do
        _keys[#_keys + 1] = FloatCurveKey.new(info.x, info.y, Enum.KeyInterpolationMode.Linear)
    end

    curve:SetKeys(_keys)

    return Curve.new(curve)
end

return {
    linear = createLinearCurve,
}

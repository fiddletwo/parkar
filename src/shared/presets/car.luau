const curve = require "@game/ReplicatedStorage/shared/utils/curve"

export type WheelSpring = {
    stiffness: number,
    damping: number,
    rest: number,
    radius: number,
}

export type CarPreset = {
    hitbox: Vector3,
    spring: WheelSpring,
    wheels: {
        fl: Vector3,
        fr: Vector3,
        rl: Vector3,
        rr: Vector3,
    },
    acceleration: {
        throttle: curve.Curve,
        coasting: number,
    },
}

const presets: { [string]: CarPreset } = {
    default = {
        hitbox = Vector3.new(4, 2, 6),
        spring = {
            stiffness = 10000,
            damping = 1000,
            rest = 2,
            radius = 1,
        },
        wheels = {
            fl = Vector3.new(-2, 0, -3),
            fr = Vector3.new(2, 0, -3),
            rl = Vector3.new(-2, 0, 3),
            rr = Vector3.new(2, 0, 3),
        },
        acceleration = {
            throttle = curve.linear {
                { x = 0, y = 500 },
                { x = 40, y = 20 },
                { x = 45, y = 0 },
            },
            coasting = 50,
        },
    },
}

export type PresetName = keyof<typeof(presets)>

return presets

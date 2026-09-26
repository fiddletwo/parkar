const curve = require "@game/ReplicatedStorage/shared/utils/curve"

export type WheelSpring = {
    stiffness: number,
    damping: number,
    rest: number,
    travel: number,
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
        throttle: number,
        braking: number,
        coasting: number,
    },
    curve: {
        throttle: curve.Curve,
        friction: curve.Curve,
    },
}

const presets: { [string]: CarPreset } = {
    default = {
        hitbox = Vector3.new(4, 2, 6),
        spring = {
            stiffness = 10000,
            damping = 1000,
            rest = 2,
            travel = 1.5,
            radius = 1,
        },
        wheels = {
            fl = Vector3.new(-2, 0, -3),
            fr = Vector3.new(2, 0, -3),
            rl = Vector3.new(-2, 0, 3),
            rr = Vector3.new(2, 0, 3),
        },
        acceleration = {
            throttle = 50,
            braking = 75,
            coasting = 8,
        },
        curve = {
            throttle = curve.linear {
                { x = 0, y = 1 },
                { x = 40, y = 0.1 },
                { x = 45, y = 0 },
            },
            friction = curve.linear {
                { x = 0, y = 1 },
                { x = 1, y = 0.2 },
            },
        },
    },
}

export type PresetName = keyof<typeof(presets)>

return presets

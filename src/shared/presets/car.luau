export type CarPreset = {
    hitbox: Vector3,
    spring: {
        stiffness: number,
        damping: number,
        rest: number,
    },
    wheel: {
        radius: number,
    },
    wheels: {
        fl: Vector3,
        fr: Vector3,
        rl: Vector3,
        rr: Vector3,
    },
}

const presets: { [string]: CarPreset } = {
    default = {
        hitbox = Vector3.new(4, 2, 6),
        spring = {
            stiffness = 1000,
            damping = 100,
            rest = 2,
        },
        wheel = {
            radius = 1.5,
        },
        wheels = {
            fl = Vector3.new(-2, 0, -3),
            fr = Vector3.new(2, 0, -3),
            rl = Vector3.new(-2, 0, 3),
            rr = Vector3.new(2, 0, 3),
        },
    },
}

export type PresetName = keyof<typeof(presets)>

return presets

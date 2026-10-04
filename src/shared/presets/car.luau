const ReplicatedStorage = game:GetService "ReplicatedStorage"

const curve = require "@game/ReplicatedStorage/shared/utils/curve"

export type WheelSpring = {
    stiffness: number,
    damping: number,
    rest: number,
    radius: number,
}

export type CarModel = Model & {
    Anchor: BasePart,
}

export type CarPreset = {
    model: CarModel?,
    hitbox: Vector3,
    mass: number,
    turnRadius: number,
    wheelWidth: number,
    spring: WheelSpring,
    wheels: {
        fl: Vector3,
        fr: Vector3,
        rl: Vector3,
        rr: Vector3,
    },
    acceleration: {
        throttle: number,
        reverse: number,
        braking: number,
        coasting: number,
        groundBoost: number,
        airBoost: number,
        yaw: number,
        pitch: number,
        roll: number,
        drag: number,
    },
    limits: {
        throttle: number,
        max: number,
    },
    curve: {
        throttle: curve.Curve,
        friction: curve.Curve,
    },
}

const presets: { [string]: CarPreset } = {
    default = {
        model = ReplicatedStorage.assets.cars.truck,
        hitbox = Vector3.new(4, 2, 6),
        mass = 400,
        turnRadius = 12,
        wheelWidth = 0.75,
        spring = {
            stiffness = 30000,
            damping = 3000,
            rest = 1,
            radius = 0.75,
        },
        wheels = {
            fl = Vector3.new(-1.625, -0.875, -2.125),
            fr = Vector3.new(1.625, -0.875, -2.125),
            rl = Vector3.new(-1.625, -0.875, 2.125),
            rr = Vector3.new(1.625, -0.875, 2.125),
        },
        acceleration = {
            throttle = 67,
            reverse = 22,
            braking = 75,
            coasting = 5,

            groundBoost = 90,
            airBoost = 160,

            yaw = 30,
            pitch = 60,
            roll = 80,

            drag = 20,
        },
        limits = {
            throttle = 45,
            max = 60,
        },
        curve = {
            throttle = curve.linear {
                { x = 0, y = 1 },
                { x = 0.8, y = 0.1 },
                { x = 1, y = 0 },
            },
            friction = curve.linear {
                { x = 0, y = 1 },
                { x = 0.7, y = 1 },
                { x = 1, y = 0.2 },
            },
        },
    },
}

export type PresetName = keyof<typeof(presets)>

return presets

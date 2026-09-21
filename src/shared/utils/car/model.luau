const presets = require "../../presets/car"
const partUtil = require "../part_util"

export type Car = Model & {
    Hitbox: Part,
}

const function createCar(preset: presets.CarPreset): Car
    const model = Instance.new "Model"

    const hitbox = Instance.new "Part"
    hitbox.Name = "Hitbox"
    hitbox.Size = preset.hitbox
    hitbox.CastShadow = false
    hitbox.EnableFluidForces = false
    hitbox.Material = Enum.Material.SmoothPlastic
    hitbox.Parent = model
    partUtil.setBlockMass(hitbox, 500)

    return model :: Car
end

return {
    create = createCar,
}

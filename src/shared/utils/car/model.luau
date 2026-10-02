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
    partUtil.setBlockMass(hitbox, preset.mass)
    partUtil.setElasticity(hitbox, 0.1)

    const car = preset.model
    if car then
        const clone = car:Clone()

        const constraint = Instance.new "Weld"
        constraint.Part0 = clone.Anchor
        constraint.Part1 = hitbox
        constraint.Parent = clone.Anchor

        hitbox.Transparency = 1
        clone.Parent = model
    end

    if hitbox.CenterOfMass ~= Vector3.zero then
        warn "Car's center of mass is not centered! Did you forget to set welded parts to massless?"
    end

    return model :: Car
end

return {
    create = createCar,
}

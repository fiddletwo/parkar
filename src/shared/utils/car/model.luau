const partUtil = require "../part_util"

export type Car = Model & {
    Hitbox: Part,
}

const function createCar(): Car
    const model = Instance.new "Model"

    const hitbox = Instance.new "Part"
    hitbox.Name = "Hitbox"
    hitbox.Size = Vector3.new(4, 2, 6)
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

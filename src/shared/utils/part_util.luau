const function setBlockMass(part: BasePart, mass: number)
    part.CustomPhysicalProperties = PhysicalProperties.new(
        mass / (part.Size.X * part.Size.Y * part.Size.Z),
        part.CurrentPhysicalProperties.Friction,
        part.CurrentPhysicalProperties.Elasticity
    )
end

const function setElasticity(part: BasePart, elasticity: number)
    part.CustomPhysicalProperties = PhysicalProperties.new(
        part.CurrentPhysicalProperties.Density,
        part.CurrentPhysicalProperties.Friction,
        elasticity,
        part.CurrentPhysicalProperties.FrictionWeight,
        100
    )
end

return {
    setBlockMass = setBlockMass,
    setElasticity = setElasticity,
}

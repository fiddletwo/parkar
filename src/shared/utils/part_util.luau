const function setBlockMass(part: BasePart, mass: number)
    part.CustomPhysicalProperties = PhysicalProperties.new(
        mass / (part.Size.X * part.Size.Y * part.Size.Z),
        part.CurrentPhysicalProperties.Friction,
        part.CurrentPhysicalProperties.Elasticity
    )
end

return {
    setBlockMass = setBlockMass,
}

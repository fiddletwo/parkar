type Force = {
    instance: Attachment & { Vector: VectorForce },
    dirty: boolean,
}

const forceTable: {
    [BasePart]: {
        [any]: Force,
    },
} = {}

-- implement a cache at some point
const function _createForce(part: BasePart, force: Vector3, position: Vector3): Force
    const forceInstance = Instance.new "Attachment"
    forceInstance.Name = "Force"
    forceInstance.WorldPosition = position

    const vectorForce = Instance.new "VectorForce"
    vectorForce.Name = "Vector"
    vectorForce.Attachment0 = forceInstance
    vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
    vectorForce.Force = force
    vectorForce.Parent = forceInstance

    forceInstance.Parent = part

    return {
        instance = forceInstance :: any,
        dirty = false,
    }
end

const function addForce(id: any, part: BasePart, force: Vector3, position: Vector3)
    if forceTable[part] == nil then
        forceTable[part] = {}
    end

    const forceInfo = forceTable[part][id]
    if forceInfo then
        const forceInstance = forceInfo.instance
        forceInstance.WorldPosition = position
        forceInstance.Vector.Force = force
        forceInfo.dirty = false
    else
        forceTable[part][id] = _createForce(part, force, position)
    end
end

const function cleanupForces()
    for part, forces in forceTable do
        -- part is destroyed
        if part.Parent == nil then
            for force, info in forces do
                info.instance:Destroy()
                forceTable[part][force] = nil
            end

            forceTable[part] = nil
        else
            for force, info in forces do
                if info.dirty then
                    info.instance:Destroy()
                    forceTable[part][force] = nil
                else
                    info.dirty = true
                end
            end
        end
    end
end

return {
    add = addForce,
    cleanup = cleanupForces,
}

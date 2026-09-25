const InstanceCache = require "./instance_cache"

type ForceInstance = Attachment & { Vector: VectorForce }

type Force = {
    instance: ForceInstance,
    dirty: boolean,
}

const forceTable: {
    [BasePart]: {
        [any]: Force,
    },
} = {}

const forceInstance = Instance.new "Attachment"
forceInstance.Name = "Force"

const vectorForce = Instance.new "VectorForce"
vectorForce.Name = "Vector"
vectorForce.Attachment0 = forceInstance
vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
vectorForce.Parent = forceInstance

const cache = InstanceCache.new<<ForceInstance>>(forceInstance :: ForceInstance, 2)

const function _createForce(part: BasePart, force: Vector3, position: Vector3): Force
    const forceInstance = cache:get()
    forceInstance.WorldPosition = position
    forceInstance.Vector.Force = force
    forceInstance.Parent = part

    return {
        instance = forceInstance,
        dirty = false,
    }
end

const function addForce(id: any, part: BasePart, force: Vector3, position: Vector3, ignoreMass: boolean?)
    if ignoreMass then
        force *= part.AssemblyMass
    end

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
                cache:done(info.instance)
                forceTable[part][force] = nil
            end

            forceTable[part] = nil
        else
            for force, info in forces do
                if info.dirty then
                    info.instance.Vector.Force = Vector3.zero
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

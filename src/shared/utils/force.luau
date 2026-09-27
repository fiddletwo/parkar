const simulation = require "../ecs/simulation"
const InstanceCache = require "./instance_cache"

const forceTable: {
    [BasePart]: {
        [any]: Force,
    },
} = {}

const modes = {
    Force = 0,
    Acceleration = 1,
    Impulse = 2,
}

type ForceInstance = Attachment & { Vector: VectorForce }
type Force = {
    instance: ForceInstance,
    dirty: boolean,
}
type ForceMode = index<typeof(modes), keyof<typeof(modes)>>

const forceInstance = Instance.new "Attachment"
forceInstance.Name = "Force"

const vectorForce = Instance.new "VectorForce"
vectorForce.Name = "Vector"
vectorForce.Attachment0 = forceInstance
vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
vectorForce.Parent = forceInstance

const cache = InstanceCache.new<<ForceInstance>>(forceInstance :: ForceInstance, 20)

const function _createForce(part: BasePart, force: Vector3, position: Vector3): Force
    const forceInstance = cache:get()
    forceInstance.WorldCFrame = CFrame.new(position)
    forceInstance.Vector.Force = Vector3.zero
    forceInstance.Parent = part

    task.defer(function()
        forceInstance.Vector.Force = force
    end)

    return {
        instance = forceInstance,
        dirty = false,
    }
end

const function _addForce(id: any, part: BasePart, force: Vector3, position: Vector3, ignoreMass: boolean?)
    if ignoreMass then
        force *= part.AssemblyMass
    end

    if forceTable[part] == nil then
        forceTable[part] = {}
    end

    const forceInfo = forceTable[part][id]
    if forceInfo then
        const forceInstance = forceInfo.instance
        forceInstance.WorldCFrame = CFrame.new(position)
        forceInstance.Vector.Force = force
        forceInfo.dirty = false
    else
        forceTable[part][id] = _createForce(part, force, position)
    end
end

const function _cleanupForces()
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

const function addForce(part: BasePart, force: Vector3, position: Vector3, mode: ForceMode?)
    if mode == nil then
        mode = modes.Force
    end

    -- hardcoded for now
    const dt = simulation:getDeltaTime(Enum.StepFrequency.Hz60)

    if mode == modes.Force then
        force *= dt
    elseif mode == modes.Acceleration then
        force *= dt * part.AssemblyMass
    end

    part:ApplyImpulseAtPosition(force, position)
end

return {
    Mode = modes,
    add = addForce,
}

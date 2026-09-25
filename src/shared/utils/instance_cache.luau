const Workspace = game:GetService "Workspace"

const cacheFolder = Instance.new "Folder"
cacheFolder.Name = "InstanceCache"
cacheFolder.Parent = Workspace

const InstanceCache = {}
InstanceCache.__index = InstanceCache

export type InstanceCache = setmetatable<{ _instance: Instance, cache: { Instance } }, typeof(InstanceCache)>

function InstanceCache.new(instance: Instance, initial: number): InstanceCache
    assert(typeof(instance) == "Instance", "instance must be an Instance")

    const self = {}
    self._instance = instance :: Instance

    const cache = {}
    for i = 0, initial, 1 do
        const clone = self._instance:Clone()
        clone.Parent = cacheFolder
        cache[#cache + 1] = clone
    end
    self.cache = cache

    return setmetatable(self, InstanceCache)
end

function InstanceCache:_create(): Instance
    const clone = self._instance:Clone()
    self.cache[#self.cache + 1] = clone
    return clone :: Instance
end

function InstanceCache:get(): Instance
    const cached = self.cache[#self.cache] or self:_create()
    self.cache[#self.cache] = nil
    return cached :: Instance
end

return InstanceCache

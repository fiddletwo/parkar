const Workspace = game:GetService "Workspace"

const cacheFolder = Instance.new "Folder"
cacheFolder.Name = "InstanceCache"
cacheFolder.Parent = Workspace

const InstanceCache = {}
InstanceCache.__index = InstanceCache

export type InstanceCache<T> = setmetatable<{ _instance: T, cache: { T } }, typeof(InstanceCache)>

function InstanceCache.new<T>(instance: T, initial: number): InstanceCache<T>
    assert(typeof(instance) == "Instance", "Instance must be an Instance")

    const self = {}
    self._instance = instance :: Instance

    const cache = {}
    for i = 0, initial, 1 do
        cache[#cache + 1] = self._instance:Clone()
    end
    self.cache = cache

    return setmetatable(self, InstanceCache)
end

function InstanceCache:get() end

return InstanceCache

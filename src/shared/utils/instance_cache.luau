const Workspace = game:GetService "Workspace"

const cacheFolder = Instance.new "Folder"
cacheFolder.Name = "InstanceCache"
cacheFolder.Parent = Workspace

const InstanceCache = {}
InstanceCache.__index = InstanceCache

export type InstanceCache<T = Instance> = setmetatable<{ cache: { T }, _instance: T }, typeof(InstanceCache)>

function InstanceCache.new<T>(instance: T, initial: number): InstanceCache<T>
    assert(typeof(instance) == "Instance", "Instance provided for cache is not an Instance")

    const self = {}
    self.cache = {}
    self._instance = instance :: Instance

    for i = 1, initial, 1 do
        const clone = self._instance:Clone()
        clone.Parent = cacheFolder
        self.cache[#self.cache + 1] = clone
    end

    return setmetatable(self, InstanceCache)
end

function InstanceCache:get<T>(): T
    const cached = table.remove<<T>>(self.cache) or self._instance:Clone() :: T
    return cached
end

function InstanceCache:done<T>(instance: T)
    local inst = instance :: Instance

    if inst.Parent == nil then
        inst = self._instance:Clone() :: Instance
    end

    inst.Parent = cacheFolder
    self.cache[#self.cache + 1] = instance
end

return InstanceCache

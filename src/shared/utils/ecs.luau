const jecs = require "@game/ReplicatedStorage/packages/jecs"
const replecs = require "@game/ReplicatedStorage/packages/replecs"
const world = require "../world"

type ComponentTable = {
    [string]: jecs.Id,
}

const function addName(components: ComponentTable)
    for name, id in components do
        world:set(id, jecs.Name, name)
    end
end

const function addShared(components: ComponentTable)
    for _, id in components do
        world:add(id, replecs.Shared)
    end
end

return {
    addName = addName,
    addShared = addShared,
}

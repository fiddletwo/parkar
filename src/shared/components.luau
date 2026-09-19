const jecs_utils = require "@game/ReplicatedStorage/packages/jecs-utils"
const replecs = require "@game/ReplicatedStorage/packages/replecs"
const ecs = require "./utils/ecs"
const world = require "./world"

const ref = jecs_utils.ref

const components = {
    -- Player
    Player = world:component<<Player>>(),

    -- Instances
    Renderable = world:component<<Model>>(),

    -- Physics
    Transform = world:component<<Vector3>>(),
}

ecs.addName(components)
ecs.addShared(components)

world:set(components.Player, replecs.CustomHandler, function(player)
    const id = ref(player)
    return id
end)

return components

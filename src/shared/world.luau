require "@game/ReplicatedStorage/packages/replecs"
const jecs = require "@game/ReplicatedStorage/packages/jecs"
const jecs_utils = require "@game/ReplicatedStorage/packages/jecs-utils"

const world = jecs.world()

jecs_utils.world(world)

return world

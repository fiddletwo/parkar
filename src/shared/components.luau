const jecs_utils = require "@game/ReplicatedStorage/packages/jecs-utils"
const replecs = require "@game/ReplicatedStorage/packages/replecs"
const _presets = require "./presets/car"
const jecs = require "@game/ReplicatedStorage/packages/jecs"
const ecs = require "./utils/ecs"
const world = require "./world"

const pair = jecs.pair
const ref = jecs_utils.ref

const components = {
    -- State
    Locked = world:entity(),

    -- Player
    Player = world:component<<Player>>(),

    -- Car
    Car = world:entity(),
    CarPreset = world:component<<_presets.PresetName>>(),
    CarOf = world:entity(),
    Wheel = world:entity(),
    WheelSpring = world:component<<_presets.WheelSpring>>(),

    -- Instances
    Renderable = world:component<<Model>>(),

    -- Physics
    Transform = world:component<<CFrame>>(),
    Position = world:component<<Vector3>>(),
    Orientation = world:component<<Vector3>>(),
    Length = world:component<<number>>(),

    -- Raycasts
    RaycastParams = world:component<<RaycastParams>>(),

    -- Camera
    ActiveCamera = world:component<<jecs.Entity>>(),
    PlayerCamera = world:component<<jecs.Entity>>(),
    Camera = world:entity(),
    FieldOfView = world:component<<number>>(),
    CameraSubject = world:component<<BasePart | Humanoid>>(),
    CameraType = world:component<<Enum.CameraType>>(),
}

ecs.addName(components)
ecs.addShared(components)

world:set(components.Player, replecs.CustomHandler, function(player)
    const id = ref(player)
    return id
end)
world:removed(components.Renderable, function(entity)
    const renderable = world:get(entity, components.Renderable)
    if renderable then
        renderable:Destroy()
    end
end)
world:add(components.CarOf, pair(jecs.OnDeleteTarget, jecs.Delete))

return components

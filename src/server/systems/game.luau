const ReplicatedStorage = game:GetService "ReplicatedStorage"
const Workspace = game:GetService "Workspace"

const ct = require "@game/ReplicatedStorage/shared/components"
const jecs = require "@game/ReplicatedStorage/packages/jecs"
const planck_runservice = require "@game/ReplicatedStorage/packages/planck-runservice"
const scheduler = require "@game/ReplicatedStorage/shared/ecs/scheduler"

const pair = jecs.pair

const function system(world: jecs.World)
    const map = ReplicatedStorage.assets.map.jump_showdown:Clone()
    map.Parent = Workspace

    const spawns = {}
    for i, spawn in map.Spawns:QueryDescendants "Attachment" do
        spawns[i] = spawn.WorldCFrame
    end

    local currentRound: jecs.Entity

    return function()
        if world:each(ct.Player)() == nil then
            return
        end

        if currentRound == nil then
            currentRound = world:entity()
            world:set(currentRound, ct.Rotation, 90)

            local i = 1
            for id in world:each(ct.Player) do
                world:set(id, ct.Spawn, spawns[i])
                i += 1
            end

            world:set(currentRound, pair(ct.Timer, ct.Countdown), {
                start = os.clock(),
                duration = 5,
                repeats = false,
            })
        end

        if world:has(currentRound, pair(ct.Timer, ct.Countdown)) then
            return
        end

        local rotation = world:get(currentRound, ct.Rotation) or 0

        map.BottomSpinner.CFrame = CFrame.Angles(0, math.rad(rotation), 0) + map.BottomSpinner.Position
        map.TopSpinner.CFrame = CFrame.Angles(0, math.rad(-rotation * 1.2) + math.pi / 2, 0) + map.TopSpinner.Position

        const dt = scheduler:getDeltaTime() :: number
        rotation += 30 * dt

        world:set(currentRound, ct.Rotation, rotation)
    end
end

return {
    name = "game",
    system = system,
    phase = planck_runservice.Phases.Update,
}

const ReplicatedStorage = game:GetService "ReplicatedStorage"
const Workspace = game:GetService "Workspace"

const ct = require "@game/ReplicatedStorage/shared/components"
const jecs = require "@game/ReplicatedStorage/packages/jecs"
const planck_runservice = require "@game/ReplicatedStorage/packages/planck-runservice"
const replicator = require "../replicator"
const scheduler = require "@game/ReplicatedStorage/shared/ecs/scheduler"

const pair = jecs.pair

const function system(world: jecs.World)
    const map = ReplicatedStorage.assets.map.jump_showdown:Clone()
    map.Parent = Workspace

    const spawns = {}
    for i, spawn in map.Spawns:QueryDescendants "Attachment" do
        spawns[i] = spawn.WorldCFrame
    end

    const countdownTime = 15
    const roundTime = 3 * 60

    local currentRound: jecs.Entity

    const function startRound(round: jecs.Entity)
        local i = 1
        for id in world:each(ct.Player) do
            world:set(id, ct.Spawn, spawns[i])
            i += 1
        end

        world:set(round, pair(ct.Timer, ct.Time), {
            start = os.clock(),
            duration = roundTime,
            repeats = false,
        })
    end

    return function()
        if world:each(ct.Player)() == nil then
            return
        end

        if currentRound == nil then
            currentRound = world:entity()
            replicator:set_networked(currentRound)
            world:set(currentRound, ct.Rotation, 90)

            world:set(currentRound, pair(ct.Timer, ct.Countdown), {
                start = os.clock(),
                duration = countdownTime,
                repeats = false,
                callback = function()
                    startRound(currentRound)
                end,
            })

            const now = Workspace:GetServerTimeNow()

            world:set(currentRound, pair(ct.Timestamp, ct.Countdown), now + countdownTime)
            world:set(currentRound, pair(ct.Timestamp, ct.Round), now + countdownTime + roundTime)

            replicator:set_relation(currentRound, ct.Timestamp)
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

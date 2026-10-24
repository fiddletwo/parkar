const ReplicatedStorage = game:GetService "ReplicatedStorage"
const Workspace = game:GetService "Workspace"

const ct = require "@game/ReplicatedStorage/shared/components"
const jecs = require "@game/ReplicatedStorage/packages/jecs"
const model = require "@game/ReplicatedStorage/shared/utils/car/model"
const planck_runservice = require "@game/ReplicatedStorage/packages/planck-runservice"
const replicator = require "../replicator"
const scheduler = require "@game/ReplicatedStorage/shared/ecs/scheduler"

const pair = jecs.pair
const Wildcard = jecs.Wildcard

const function system(world: jecs.World)
    const map = ReplicatedStorage.assets.map.jump_showdown:Clone()
    map.Parent = Workspace

    const spawns = {}
    for i, spawn in map.Spawns:QueryDescendants "Attachment" do
        spawns[i] = spawn.WorldCFrame
    end

    const cars = world:query(ct.Renderable):with(pair(ct.CarOf, Wildcard)):cached()

    const countdownTime = 10
    const roundTime = 3 * 60
    const deathZone = map.WorldPivot.Position.Y - 80

    local currentRound: jecs.Entity?

    const function startRound(round: jecs.Entity)
        local i = 1
        for id in world:each(ct.Player) do
            world:set(id, ct.Spawn, spawns[i])
            i += 1
        end

        -- allows for extra time for cars to spawn in
        task.defer(function()
            world:set(round, pair(ct.Timer, ct.Round), {
                start = os.clock(),
                duration = roundTime,
                repeats = false,
                callback = function()
                    for id in cars do
                        world:delete(id)
                    end

                    world:delete(round)
                    currentRound = nil
                end,
            })
        end)
    end

    return function()
        if world:each(ct.Player)() == nil then
            return
        end

        if currentRound == nil then
            const round = world:entity()

            replicator:set_networked(round)
            world:set(round, ct.Rotation, 90)

            world:set(round, pair(ct.Timer, ct.Countdown), {
                start = os.clock(),
                duration = countdownTime,
                repeats = false,
                callback = function()
                    startRound(round)
                end,
            })

            const now = Workspace:GetServerTimeNow()

            world:set(round, pair(ct.Timestamp, ct.Countdown), now + countdownTime)
            world:set(round, pair(ct.Timestamp, ct.Round), now + countdownTime + roundTime)

            replicator:set_relation(round, ct.Timestamp)

            currentRound = round
        end

        if currentRound then
            if
                world:has(currentRound, pair(ct.Timer, ct.Countdown))
                or not world:has(currentRound, pair(ct.Timer, ct.Round))
            then
                return
            end

            local rotation = world:get(currentRound, ct.Rotation) or 0

            map.BottomSpinner.CFrame = CFrame.Angles(0, math.rad(rotation), 0) + map.BottomSpinner.Position
            map.TopSpinner.CFrame = CFrame.Angles(0, math.rad(-rotation * 1.2) + math.pi / 2, 0)
                + map.TopSpinner.Position

            const dt = scheduler:getDeltaTime() :: number
            rotation += 30 * dt

            world:set(currentRound, ct.Rotation, rotation)

            local carsLeft = 0
            for id, car in cars do
                const model = car :: model.Car
                if model.Hitbox.Position.Y < deathZone then
                    world:delete(id)
                else
                    carsLeft += 1
                end
            end

            if carsLeft == 0 then
                world:delete(currentRound)
                currentRound = nil
            end
        end
    end
end

return {
    name = "game",
    system = system,
    phase = planck_runservice.Phases.Update,
}

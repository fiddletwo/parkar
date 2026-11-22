const ReplicatedStorage = game:GetService "ReplicatedStorage"
const Workspace = game:GetService "Workspace"

const ct = require "@game/ReplicatedStorage/shared/components"
const jecs = require "@game/ReplicatedStorage/packages/jecs"
const model = require "@game/ReplicatedStorage/shared/utils/car/model"
const network = require "../network"
const planck_runservice = require "@game/ReplicatedStorage/packages/planck-runservice"
const replicator = require "../replicator"
const scheduler = require "@game/ReplicatedStorage/shared/ecs/scheduler"

const pair = jecs.pair
const Wildcard = jecs.Wildcard

const function system(world: jecs.World)
    const map = ReplicatedStorage.assets.map.jump_showdown:Clone()
    map.Parent = Workspace

    const firstHighlight = Instance.new "Highlight"
    const secondHighlight = Instance.new "Highlight"

    firstHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
    secondHighlight.DepthMode = Enum.HighlightDepthMode.Occluded

    firstHighlight.Enabled = false
    secondHighlight.Enabled = false

    firstHighlight.Parent = map
    secondHighlight.Parent = map

    const spawns = {}
    for i, spawn in map.Spawns:QueryDescendants "Attachment" do
        spawns[i] = spawn.WorldCFrame
    end

    const platforms = {}
    for i, platform in map.Octants:QueryDescendants "BasePart" do
        platforms[i] = platform
    end

    const cars = world:query(ct.Renderable):with(pair(ct.CarOf, Wildcard)):cached()

    const countdownTime = 10
    const roundTime = 5
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

                    for i, platform in platforms do
                        platform.Transparency = 0
                        platform.CanQuery = true
                        platform.CanCollide = true
                    end

                    firstHighlight.Enabled = false
                    secondHighlight.Enabled = false

                    world:delete(round)
                    currentRound = nil
                end,
            })

            world:set(round, pair(ct.Timer, ct.One), {
                start = os.clock(),
                duration = roundTime * 0.6,
                repeats = true,
                callback = function()
                    const random = math.random(1, 4)
                    const firstPlatform = platforms[random]
                    const secondPlatform = platforms[random + 4]

                    firstHighlight.Parent = firstPlatform
                    secondHighlight.Parent = secondPlatform

                    firstHighlight.Enabled = true
                    secondHighlight.Enabled = true

                    task.delay(3, function()
                        firstPlatform.Transparency = 1
                        firstPlatform.CanCollide = false
                        firstPlatform.CanQuery = false

                        secondPlatform.Transparency = 1
                        secondPlatform.CanCollide = false
                        secondPlatform.CanQuery = false

                        firstHighlight.Enabled = false
                        secondHighlight.Enabled = false
                    end)
                end,
            })
        end)
    end

    const players = world:query(ct.Player):with(ct.Ready):cached()

    return function()
        local playersReady = 0
        for _ in players do
            playersReady += 1
        end

        if playersReady == 0 then
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
                    const playerEntity = world:target(id, ct.CarOf)
                    if playerEntity then
                        const player = world:get(playerEntity, ct.Player)
                        if player then
                            network.Game.SendPlayerFail.fire(player)
                        end
                    end
                    world:delete(id)
                else
                    carsLeft += 1
                end
            end

            if carsLeft == 0 then
                world:delete(currentRound)
                currentRound = nil

                for i, platform in platforms do
                    platform.Transparency = 0
                    platform.CanCollide = true
                end

                firstHighlight.Enabled = false
                secondHighlight.Enabled = false
            end
        end
    end
end

return {
    name = "game",
    system = system,
    phase = planck_runservice.Phases.Update,
}

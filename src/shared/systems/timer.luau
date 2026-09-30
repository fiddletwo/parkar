const jecs = require "@game/ReplicatedStorage/packages/jecs"
const planck_runservice = require "@game/ReplicatedStorage/packages/planck-runservice"
const ct = require "../components"

const pair = jecs.pair
const Wildcard = jecs.Wildcard

const function system(world: jecs.World)
    const timers = world:query(pair(ct.Timer, Wildcard)):cached()

    return function()
        const now = os.clock()

        for id in timers do
            local nth = 0
            while true do
                const t = world:target(id, ct.Timer, nth)
                if not t then
                    break
                end

                const timer = world:get(id, pair(ct.Timer, t)) :: ct.Timer
                if (timer.start + timer.duration) < now then
                    if timer.repeats then
                        timer.start += timer.duration
                    else
                        world:remove(id, pair(ct.Timer, t))
                    end
                end

                nth += 1
            end
        end
    end
end

return {
    name = "timer",
    system = system,
    phase = planck_runservice.Phases.Update,
}

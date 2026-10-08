const RunService = game:GetService "RunService"

const planck = require "@game/ReplicatedStorage/packages/planck"

const Phase = planck.Phase
const Pipeline = planck.Pipeline

const phases = {
    FixedUpdate = Phase.new "FixedUpdate",
}

const pipelines = {
    FixedUpdate = Pipeline.new("FixedUpdate"):insert(phases.FixedUpdate),
}

const dt = 1 / 60

const function update(cb)
    local accumulator = 0

    return RunService.Heartbeat:Connect(function(frameTime)
        accumulator += frameTime

        while accumulator >= dt do
            cb()
            accumulator -= dt
        end
    end)
end

const function getDeltaTime(_): number
    return dt
end

const Plugin = {}
Plugin.__index = Plugin

function Plugin.build(_, scheduler: planck.Scheduler<...unknown>)
    for _, pipeline in pipelines :: { [string]: planck.Pipeline } do
        scheduler:insert(pipeline, update)
    end
end

function Plugin.new()
    const plugin = {}
    return setmetatable(plugin, Plugin)
end

return {
    Plugin = Plugin,
    Phases = phases,
    Pipelines = pipelines,
    getDeltaTime = getDeltaTime,
}

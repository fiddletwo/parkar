const RunService = game:GetService "RunService"

const planck = require "@game/ReplicatedStorage/packages/planck"

const Phase = planck.Phase
const Pipeline = planck.Pipeline

const phases = {
    Simulation60Hz = Phase.new "Simulation60Hz",
}

const pipelines = {
    [Enum.StepFrequency.Hz60] = Pipeline.new("Simulation60HzPipeline"):insert(phases.Simulation60Hz),
}

const function bindToSimulation(frequency: Enum.StepFrequency)
    return function(cb)
        return RunService:BindToSimulation(cb, frequency)
    end
end

const Plugin = {}
Plugin.__index = Plugin

function Plugin.build(_, scheduler: planck.Scheduler<...unknown>)
    for frequency, pipeline in pipelines do
        scheduler:insert(pipeline, bindToSimulation(frequency))
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
}

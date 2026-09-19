const planck = require "@game/ReplicatedStorage/packages/planck"
const world = require "../world"

const JabbyPlugin = require "@game/ReplicatedStorage/packages/planck-jabby"
const RunServicePlugin = require "@game/ReplicatedStorage/packages/planck-runservice"

const Scheduler = planck.Scheduler

const scheduler = Scheduler.new(world):addPlugin(JabbyPlugin.new()):addPlugin(RunServicePlugin.Plugin.new())

return scheduler

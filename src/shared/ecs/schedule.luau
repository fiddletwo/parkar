const ContextActionService = game:GetService "ContextActionService"
const RunService = game:GetService "RunService"

const jecs = require "@game/ReplicatedStorage/packages/jecs"
const planck = require "@game/ReplicatedStorage/packages/planck"
const jabby = require "@game/ReplicatedStorage/packages/jabby"
const ct = require "../components"
const scheduler = require "./scheduler"

const IS_CLIENT = RunService:IsClient()
const IS_STUDIO = RunService:IsStudio()

const function createWidget(_, state: Enum.UserInputState): Enum.ContextActionResult
    const client = jabby.obtain_client()
    if state ~= Enum.UserInputState.Begin then
        return Enum.ContextActionResult.Pass
    end
    client.spawn_app(client.apps.home :: any, nil)
    return Enum.ContextActionResult.Sink
end

const function schedule(world: jecs.World, ...: ModuleScript)
    const modules = { ... }
    const systems: { planck.SystemTable<jecs.World> } = {}

    const function getEntityFromPart(part: BasePart): (jecs.Entity?, PVInstance?)
        for id, model in world:query(ct.Renderable) do
            if not part:IsDescendantOf(model) then
                continue
            end
            return id, model
        end

        return nil, nil
    end

    for i, module in modules do
        systems[i] = require(module) :: any
    end

    if #systems ~= 0 then
        scheduler:addSystems(systems)
    end

    jabby.register {
        applet = jabby.applets.world,
        name = `World - {IS_CLIENT and "Client" or "server"}`,
        configuration = {
            world = world,
            get_entity_from_part = getEntityFromPart,
        } :: any,
    }
    jabby.set_check_function(function(player)
        return IS_STUDIO
    end)

    if IS_CLIENT then
        ContextActionService:BindAction("Open Jabby Home", createWidget, false, Enum.KeyCode.F4)
    end
end

return schedule

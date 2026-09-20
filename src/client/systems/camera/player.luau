const UserInputService = game:GetService "UserInputService"

const jecs = require "@game/ReplicatedStorage/packages/jecs"
const planck_runservice = require "@game/ReplicatedStorage/packages/planck-runservice"
const car = require "../../utils/car"
const ct = require "@game/ReplicatedStorage/shared/components"

const function system(world: jecs.World)
    local camera = world:get(ct.PlayerCamera, ct.PlayerCamera)
    if not camera then
        const id = world:entity()
        world:add(id, ct.Camera)
        world:set(id, ct.FieldOfView, 80)
        world:set(id, ct.CameraType, Enum.CameraType.Scriptable)
        world:set(id, ct.Orientation, Vector3.zero)
        world:set(id, ct.Transform, CFrame.identity)

        world:set(ct.PlayerCamera, ct.PlayerCamera, id)
        camera = id
    end

    const car = car.model()
    if not car or car.Parent == nil or not car:FindFirstChild "Hitbox" then
        return
    end

    const active = world:get(ct.ActiveCamera, ct.ActiveCamera) == camera
    if camera and active then
    end
end

return {
    name = "camera/player",
    system = system,
    phase = planck_runservice.Phases.PreRender,
}

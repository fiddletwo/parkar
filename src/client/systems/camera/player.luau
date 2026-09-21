const UserInputService = game:GetService "UserInputService"
const Workspace = game:GetService "Workspace"

const jecs = require "@game/ReplicatedStorage/packages/jecs"
const planck_runservice = require "@game/ReplicatedStorage/packages/planck-runservice"
const inputs = require "../../inputs"
const car = require "../../utils/car"
const ct = require "@game/ReplicatedStorage/shared/components"
const scheduler = require "@game/ReplicatedStorage/shared/ecs/scheduler"
const config = require "../../config/player"
const action = require "@game/ReplicatedStorage/shared/utils/input/action"

const userSettings = UserSettings():GetService "UserGameSettings"

const params = RaycastParams.new()
params.ExcludeInstances = { Workspace.Cars }

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

    const carModel = car.model()
    if not carModel or carModel.Parent == nil or not carModel:FindFirstChild "Hitbox" then
        return
    end

    const active = world:get(ct.ActiveCamera, ct.ActiveCamera) == camera
    if camera and active then
        const locked = world:has(camera, ct.Locked)
        if action(inputs.lockCamera) then
            if locked then
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                UserInputService.MouseIconEnabled = true
                world:remove(camera, ct.Locked)
            else
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                UserInputService.MouseIconEnabled = false
                world:add(camera, ct.Locked)
            end
        end

        const orientation = world:get(camera, ct.Orientation) :: Vector3
        local x = orientation.X
        local y = orientation.Y

        const _, state = action(inputs.cameraRotation)
        const delta = state.input2D
            * scheduler:getDeltaTime() :: number
            * userSettings.MouseSensitivity
            * config.camera.multiplier

        x = (x - delta.X) % (math.pi * 2)
        y = math.clamp(y - delta.Y, math.rad(-89), math.rad(89))

        const angles = CFrame.Angles(0, x, 0) * CFrame.Angles(y, 0, 0)
        world:set(camera, ct.Orientation, Vector3.new(x, y, 0))

        const root = carModel.Hitbox.Position
        const target = root + angles:VectorToWorldSpace(config.camera.offset)
        const ray = Workspace:Raycast(root, target - root, params)

        world:set(
            camera,
            ct.Transform,
            CFrame.new(ray and ray.Position + ray.Normal * config.camera.clipping or target) * angles
        )
    end
end

return {
    name = "camera/player",
    system = system,
    phase = planck_runservice.Phases.PreRender,
}

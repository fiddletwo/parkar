const Workspace = game:GetService "Workspace"

const jecs = require "@game/ReplicatedStorage/packages/jecs"
const planck_runservice = require "@game/ReplicatedStorage/packages/planck-runservice"
const ct = require "@game/ReplicatedStorage/shared/components"

const currentCamera = Workspace.CurrentCamera

const function system(world: jecs.World)
    local activeCamera = world:get(ct.ActiveCamera, ct.ActiveCamera)
    if not activeCamera then
        for camera in world:each(ct.Camera) do
            world:set(ct.ActiveCamera, ct.ActiveCamera, camera)
            activeCamera = camera
            break
        end
    end

    if activeCamera then
        const fov = world:get(activeCamera, ct.FieldOfView)
        if fov and fov ~= currentCamera.FieldOfView then
            currentCamera.FieldOfView = fov
        end

        const cameraSubject = world:get(activeCamera, ct.CameraSubject)
        if cameraSubject then
            currentCamera.CameraSubject = cameraSubject
        end

        const cameraType = world:get(activeCamera, ct.CameraType) or Enum.CameraType.Custom
        currentCamera.CameraType = cameraType

        const transform = world:get(activeCamera, ct.Transform)
        if currentCamera.CameraType == Enum.CameraType.Scriptable and transform then
            currentCamera.CFrame = transform
        end
    end
end

return {
    name = "camera/update",
    system = system,
    phase = planck_runservice.Phases.PreRender,
}

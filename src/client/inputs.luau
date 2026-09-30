const input = require "@game/ReplicatedStorage/shared/utils/input"

const inputs = {
    lockCamera = {
        keycodes = { Enum.KeyCode.LeftControl },
    },
    cameraRotation = {
        type = Enum.InputActionType.Direction2D,
        keycodes = { Enum.KeyCode.Thumbstick2, Enum.KeyCode.MouseDelta, Enum.KeyCode.TouchDelta },
    },
    movement = {
        type = Enum.InputActionType.Direction2D,
        input2D = input.input2D(Enum.KeyCode.W, Enum.KeyCode.S, Enum.KeyCode.A, Enum.KeyCode.D),
    },
    roll = {
        type = Enum.InputActionType.Direction1D,
        input1D = input.input1D(Enum.KeyCode.E, Enum.KeyCode.Q),
    },
    jump = {
        keycodes = { Enum.KeyCode.MouseRightButton },
    },
}

return input.read("GameplayContext", inputs)

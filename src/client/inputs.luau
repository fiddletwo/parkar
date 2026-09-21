const input = require "@game/ReplicatedStorage/shared/utils/input"

const inputs = {
    lockCamera = {
        keycodes = { Enum.KeyCode.LeftControl },
    },
    movement = {
        type = Enum.InputActionType.Direction2D,
        input2D = input.input2D(Enum.KeyCode.W, Enum.KeyCode.S, Enum.KeyCode.A, Enum.KeyCode.D),
    },
}

return input.read("GameplayContext", inputs)

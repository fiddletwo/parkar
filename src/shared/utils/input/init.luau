const ReplicatedStorage = game:GetService "ReplicatedStorage"

export type Input2D = {
    up: Enum.KeyCode,
    down: Enum.KeyCode,
    left: Enum.KeyCode,
    right: Enum.KeyCode,
    clamp: boolean?,
}

export type InputSchema = {
    type: Enum.InputActionType?,
    keycodes: { Enum.KeyCode }?,
    input2D: Input2D?,
}
export type InputTable = {
    [string]: InputSchema,
}

export type ActionState = {
    pressed: boolean,
    released: boolean,
    held: boolean,
    input2D: Vector2,
}

const inputFolder = ReplicatedStorage:FindFirstChild "Inputs" or Instance.new "Folder"
inputFolder.Name = "Inputs"
inputFolder.Parent = ReplicatedStorage

const function input2D(
    up: Enum.KeyCode,
    down: Enum.KeyCode,
    left: Enum.KeyCode,
    right: Enum.KeyCode,
    clamp: boolean?
): Input2D
    return {
        up = up,
        down = down,
        left = left,
        right = right,
        clamp = clamp,
    }
end

const function readInputs(contextName: string, inputs: InputTable): { [string]: InputAction }
    const context = Instance.new "InputContext"
    context.Name = contextName
    context.Priority = 1000
    context.Parent = inputFolder

    const actions: { [string]: InputAction } = {}

    for name, schema in inputs do
        const inputType = schema.type or Enum.InputActionType.Bool
        const action = Instance.new "InputAction"
        action.Name = name
        action.Type = inputType

        if schema.keycodes then
            for _, keycode in schema.keycodes do
                const binding = Instance.new "InputBinding"
                binding.Name = keycode.Name
                binding.KeyCode = keycode
                binding.Parent = action
            end
        end
        const input2D = schema.input2D
        if input2D then
            const binding = Instance.new "InputBinding"
            binding.Name = "Input2D"
            binding.Up = input2D.up
            binding.Down = input2D.down
            binding.Left = input2D.left
            binding.Right = input2D.right
            binding.ClampMagnitudeToOne = input2D.clamp or true
            binding.Parent = action
        end

        action.Parent = context
        actions[name] = action
    end

    return actions
end

return {
    read = readInputs,
    input2D = input2D,
}

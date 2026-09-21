type ActionState = {
    pressed: boolean,
    released: boolean,
    held: boolean,
    input2D: Vector2,
}

const actions: { [InputAction]: ActionState } = {}

const function actionState(inputAction: InputAction): ActionState
    if actions[inputAction] then
        return actions[inputAction]
    end

    const state = {
        pressed = false,
        released = false,
        held = false,
        input2D = Vector2.zero,
    }
    actions[inputAction] = state

    return state
end

const function action(inputAction: InputAction): (boolean, ActionState, boolean)
    const state = actionState(inputAction)

    const wasHeld = state.held
    const held = inputAction:GetState()

    if inputAction.Type == Enum.InputActionType.Bool then
        state.pressed = held and not wasHeld
        state.released = not held and wasHeld
        state.held = held
    elseif inputAction.Type == Enum.InputActionType.Direction2D then
        state.input2D = held
    end

    return state.pressed, state, state.released
end

return action

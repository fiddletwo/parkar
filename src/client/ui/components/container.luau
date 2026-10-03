const vide = require "@game/ReplicatedStorage/packages/vide"
const ui_types = require "../ui_types"

const create = vide.create

export type ContainerProps = ui_types.WithChildren<{
    AnchorPoint: ui_types.MaybeSource<Vector2>?,
    Position: ui_types.MaybeSource<UDim2>?,
    Rotation: ui_types.MaybeSource<number>?,
    Size: ui_types.MaybeSource<UDim2>?,
    ZIndex: ui_types.MaybeSource<number>?,
}>

const function Container(props: ContainerProps)
    return create "Frame" {
        Active = false,
        AnchorPoint = props.AnchorPoint,
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Interactable = false,
        Position = props.Position,
        Rotation = props.Rotation,
        Selectable = false,
        Size = props.Size,
        ZIndex = props.ZIndex,

        table.unpack(props),
    }
end

return Container

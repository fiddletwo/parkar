const vide = require "@game/ReplicatedStorage/packages/vide"
const ui_types = require "../ui_types"

const create = vide.create

export type PaddingProps = {
    Bottom: ui_types.MaybeSource<UDim>?,
    Left: ui_types.MaybeSource<UDim>?,
    Right: ui_types.MaybeSource<UDim>?,
    Top: ui_types.MaybeSource<UDim>?,
}

const function Padding(props: PaddingProps)
    return create "UIPadding" {
        PaddingBottom = props.Bottom,
        PaddingLeft = props.Left,
        PaddingRight = props.Right,
        PaddingTop = props.Top,
    }
end

return Padding

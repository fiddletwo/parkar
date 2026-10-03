export type MaybeSource<T> = T | () -> T

-- export type WithChildren = {
--     [number]: any,
-- }

export type function WithChildren(ty)
    if ty:is "table" then
        ty:setindexer(types.number, types.any)
    end
    return ty
end

return {}

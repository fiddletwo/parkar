const function projectOnPlane(vect: Vector3, normal: Vector3): Vector3
    return vect - normal * vect:Dot(normal)
end

return {
    projectOnPlane = projectOnPlane,
    CANCEL_Y = Vector3.new(1, 0, 1),
}

#HIT RECORD STRUCT

"""
struct HitRecord
    Creates a 3D unit sphere centered in the origin of the axes. A transfromation can be passed to translate and transform it into an ellipsoid

    world_point::Point --> 3D point where the intersection occurred
    normal::Normal --> surface normal vector
    surface_point::Vec2d --> coordinates of the intersection
    t::Float64 --> parameter associated with the intersection
    ray::Ray --> light ray that caused the intersection
"""
struct HitRecord

    world_point::Point
    normal::Normal
    surface_point::Vec2d
    t::Float64
    ray::Ray

end

function is_close(HR1::HitRecord, HR2::HitRecord, epsilon=1e-5)

    """Check whether two `HitRecord` represent the same hit event or not"""
    return ( is_close(HR1.world_point, HR2.world_point, epsilon) &&
    is_close(HR1.normal, HR2.normal, epsilon) &&
    is_close(HR1.surface_point, HR2.surface_point, epsilon) &&
    abs(HR1.t - HR2.t) < epsilon &&
    is_close(HR1.ray, HR2.ray, epsilon))

end
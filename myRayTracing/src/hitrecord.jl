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
#HIT RECORD STRUCT

"""
struct HitRecord
    Creates a 3D unit sphere centered in the origin of the axes. A transfromation can be passed to translate and transform it into an ellipsoid
"""
struct HitRecord

    world_point::Point
    normal::Normal
    surface_point::Vec2d
    t::Float64
    ray::Ray

end
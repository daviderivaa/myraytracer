#SHAPE STRUCTS
using LinearAlgebra

#DEFINING AN ABSTRACT TYPE FOR SHAPES
"""Abstarct struct for shapes"""
abstract type Shape
end

"""Abstarct method for ray_intersection"""
function ray_intersection(shape::Shape, r::Ray)
    throw(Type_error("ray_intersection method not implemented for $(typeof(shape))"))
end

"""Abstarct method for quick_ray_intersection"""
function quick_ray_intersection(shape::Shape, r::Ray)
    throw(Type_error("quick_ray_intersection method not implemented for $(typeof(shape))"))
end

#DEFINING SUBSTRUCTS
#SPHERE STRUCT
"""
struct Sphere <: Shape
    Creates a 3D unit sphere centered in the origin of the axes. 

    - T::Transformation --> The transformation applied to the unit sphere in the origin to re-scale it 
                            (eventually transforming it into an ellipsoid) and translate it in the right location

"""
struct Sphere <: Shape

    T::Transformation

    function Sphere(T::Transformation=Tranformation(Matrix{Float64}(I(4))))
        new(T)
    end

end

"""
function _sphere_normal(p, r)
    it returns the normal to the unit sphere surface in a given point, chosen in order to have the opposite direction of the incoming ray
"""
function _sphere_normal(p::Point, r::Ray)
    n = Normal(p.x, p.y, p.z)
    if (n * r.dir) < 0
        return n
    else
        return neg(n)
    end
end

"""
function _xyz_to _uv(p)
    given a point on the sphere, in returns its (u,v) 2D form
"""
function _xyz_to_uv(p::Point)
    u = atan(p.y, p.x) / (2π)
    v = acos(p.z) / π
    u = u >= 0.0 ? u : u + 1.0
    return Vec2d(u,v)
end

"""
function ray_intersection(shape, r)
    given a sphere and a ray, it returns the HitRecord for the first intersection between the ray and the sphere
"""
function ray_intersection(shape::Sphere, r::Ray)
    inv_r = inverse(shape.T)(r)
    o_vec = Point_to_Vec(inv_r.origin)

    a = squared_norm(inv_r.dir)
    b = o_vec * inv_r.dir #tecnically is b/2, but we will use delta/4
    c = squared_norm(o_vec) - 1
    delta = b*b - a*c #it's delta/4

    if delta <= 0
        return nothing
    end
 
    sqrt_delta = √(delta)

    t_1 = ( -b - sqrt_delta ) / a
    t_2 = ( -b + sqrt_delta ) / a

    if (t_1 > inv_r.tmin) && (t_1 < inv_r.tmax)
        t_hit = t_1
    elseif (t_2 > inv_r.tmin) && (t_2 < inv_r.tmax)
        t_hit = t_2
    else
        return nothing
    end

    point_hit = at(inv_r, t_hit)

    return HitRecord( (shape.T)(point_hit), #hitted point in the world
                      (shape.T)(_sphere_normal(point_hit, inv_r)), #normal at the surface in the world
                      (_xyz_to_uv(point_hit)), #(u,v) vec hitted on the surface
                      t_hit, #t
                      r #ray
                    )

end

"""
function quick_ray_intersection(shape, r)
    given a sphere and a ray, it returns true/false if there is/isn't intersection
"""
function quick_ray_intersection(shape::Sphere, r::Ray)
    inv_r = inverse(shape.T)(r)
    o_vec = Point_to_Vec(inv_r.origin)

    a = squared_norm(inv_r.dir)
    b = o_vec * inv_r.dir #tecnically is b/2, but we will use delta/4
    c = squared_norm(o_vec) - 1
    delta = b*b - a*c #it's delta/4

    if delta <= 0
        return false
    end
 
    sqrt_delta = √(delta)

    t_1 = ( -b - sqrt_delta ) / a
    t_2 = ( -b + sqrt_delta ) / a

    if (t_1 > inv_r.tmin) && (t_1 < inv_r.tmax) || (t_2 > inv_r.tmin) && (t_2 < inv_r.tmax)
        return true
    else
        return false
    end
end
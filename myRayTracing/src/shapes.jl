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

    return HitRecord( shape.T(point_hit), #hitted point in the world
                      shape.T(_sphere_normal(point_hit, inv_r)), #normal at the surface in the world
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


################################################################################

#PLANE STRUCT
"""
struct Plane <: Shape
    Creates a plane (if not transformed, it's the x-y plane). 

    - T::Transformation --> The transformation applied to the plane to rotate it and translate it in the right location.

"""
struct Plane <: Shape

    T::Transformation

    function Plane(T::Transformation=Tranformation(Matrix{Float64}(I(4))))
        new(T)
    end

end

"""
function _plane_normal(p, r)
    it returns the normal to the plane x-y, chosen in order to have the opposite direction of the incoming ray
"""
function _plane_normal(r::Ray)
    if (r.dir.z) >= 0
        return Normal(0.0, 0.0, -1.0)
    else
        return Normal(0.0, 0.0, 1.0)
    end
end

"""
function _xy_to _uv(p)
    given a point on the x-y plane, in returns its (u,v) 2D form
"""
function _xy_to_uv(p::Point)
    u = p.x - floor(p.x)
    v = p.y - floor(p.y)
    return Vec2d(u,v)
end

"""
function ray_intersection(shape, r)
    given a plane and a ray, it returns the HitRecord for the intersection between the ray and the sphere
"""
function ray_intersection(shape::Plane, r::Ray)

    inv_r = inverse(shape.T)(r)

    if inv_r.dir.z == 0
        return nothing
    end
 
    t_hit = inv_r.origin.z / inv_r.dir.z
    point_hit = at(inv_r, t_hit)

    return HitRecord( shape.T(point_hit), #hitted point in the world
                      shape.T(_plane_normal(inv_r)), #normal at the surface in the world
                      (_xy_to_uv(point_hit)), #(u,v) vec hitted on the surface
                      t_hit, #t
                      r #ray
                    )

end

"""
function quick_ray_intersection(shape, r)
    given a plane and a ray, it returns true/false if there is/isn't intersection
"""
function quick_ray_intersection(shape::Plane, r::Ray)
    inv_r = inverse(shape.T)(r)

    if inv_r.dir.z == 0
        return false
    else 
        return true
    end
end

#################################################################################

#CSG

"""
function _transform_hit(hit::HitRecord, T::Transformation)
    Necessary function for the "composition" of the transformation in CSG
"""
function _transform_hit(hit::HitRecord, T::Transformation)
    return HitRecord(
        T(hit.point),
        T(hit.normal),
        hit.uv,
        hit.t,
        hit.ray
    )
end

"""
function _ray_interval(shape::Shape, r::Ray)
    This function calculates the interval in which the ray stays in the shape, necessary because a ray can hit both shapes without hitting their intersections
"""
function _ray_interval(shape::Shape, r::Ray)

    hit1 = ray_intersection(shape, r)
    if hit1 === nothing
        return nothing
    end

    # Trova anche l’uscita dalla shape
    new_r = Ray(at(r, hit1.t + 1e-5), r.dir, 1e-5, r.tmax)
    hit2 = ray_intersection(shape, new_r)

    if hit2 === nothing
        return nothing
    end

    t_enter = hit1.t
    t_exit = hit2.t
    return (min(t_enter, t_exit), max(t_enter, t_exit))

end


#UNION
"""
new shape type for union in CSG:
- s1::Shape --> first shape
- s2::Shape --> second shape
- T::Transformation --> applied transformation
"""
struct union_shape <: Shape

    s1::Shape
    s2::Shape
    T::Transformation

    function union_shape(s1, s2, T::Transformation=Tranformation(Matrix{Float64}(I(4))))
        new(s1, s2, T)
    end

end

"""
function ray_intersection(u_shape::union_shape, r::Ray)
    given a union of shapes and a ray, it returns the HitRecord for the first intersection between the ray and the shapes's union
"""
function ray_intersection(u_shape::union_shape, r::Ray)

    hit1 = ray_intersection(u_shape.s1, r)
    hit2 = ray_intersection(u_shape.s2, r)

    if hit1 === nothing && hit2 === nothing
        return nothing
    end

    if hit1 === nothing
        return _transform_hit(hit2, u_shape.T)
    elseif hit2 === nothing
        return _transform_hit(hit1, u_shape.T)
    end

    closest_hit = hit1.t < hit2.t ? hit1 : hit2
    return _transform_hit(closest_hit, u_shape.T)

end

#INTERSECTION
"""
new shape type for intersection in CSG:
- s1::Shape --> first shape
- s2::Shape --> second shape
- T::Transformation --> applied transformation
"""
struct intersec_shape <: Shape

    s1::Shape
    s2::Shape
    T::Transformation

    function intersec_shape(s1, s2, T::Transformation=Tranformation(Matrix{Float64}(I(4))))
        new(s1, s2, T)
    end

end

"""
function ray_intersection(i_shape::intersec_shape, r::Ray)
    given a n intersection of shapes and a ray, it returns the HitRecord for the first intersection between the ray and the shapes's intersection
"""
function ray_intersection(i_shape::intersec_shape, r::Ray)

    inv_r = inverse(i_shape.T)(r)

    interval1 = _ray_interval(i_shape.s1, inv_r)
    interval2 = _ray_interval(i_shape.s2, inv_r)

    if interval1 === nothing || interval2 === nothing
        return nothing
    end

    t_enter = max(interval1[1], interval2[1])
    t_exit  = min(interval1[2], interval2[2])

    if t_enter >= t_exit
        return nothing
    end

    #If the code arrives here we know the ray hits the intersection

    point_hit = at(inv_r, t_enter)
    normal = _sphere_normal(point_hit, inv_r)

    hit = HitRecord(
        i_shape.T(point_hit),
        i_shape.T(normal),
        _xyz_to_uv(point_hit),
        t_enter,
        r
    )

    return hit

end

#DIFFERENCE
"""
new shape type for difference in CSG:
- s1::Shape --> first shape (in this case order counts)
- s2::Shape --> second shape
- T::Transformation --> applied transformation
"""
struct diff_shape <: Shape

    s1::Shape
    s2::Shape
    T::Transformation

    function diff_shape(s1::Shape, s2::Shape, T::Transformation=Tranformation(Matrix{Float64}(I(4))))
        new(s1, s2, T)
    end

end

"""
function ray_intersection(d_shape::diff_shape, r::Ray)
    given a difference of shapes and a ray, it returns the HitRecord for the first intersection between the ray and the shapes's difference
"""
function ray_intersection(d_shape::diff_shape, r::Ray)

    #TO DO...

end
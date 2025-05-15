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

"""Abstract method for normals"""
function _shape_normal(shape::Shape, r::Ray, p::Point)
    throw(Type_error("_shape_normal method not implemented for $(typeof(shape))"))
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

    function Sphere(T::Transformation=Transformation(Matrix{Float64}(I(4))))
        new(T)
    end

end

"""
function _shape_normal(s, p, r)
    it returns the normal to the unit sphere surface in a given point, chosen in order to have the opposite direction of the incoming ray
"""
function _shape_normal(s::Sphere, r::Ray, p::Point)
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
    z_clamped = clamp(p.z, -1.0, 1.0)
    v = acos(z_clamped) / π
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
                      shape.T(_shape_normal(shape, inv_r, point_hit)), #normal at the surface in the world
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

    function Plane(T::Transformation=Transformation(Matrix{Float64}(I(4))))
        new(T)
    end

end

"""
function _shape_normal(pl, r, p::Point = nothing)
    it returns the normal to the plane x-y, chosen in order to have the opposite direction of the incoming ray
"""
function _shape_normal(pl::Plane, r::Ray, p::Point = nothing)
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
                      shape.T(_shape_normal(shape, inv_r)), #normal at the surface in the world
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
    Necessary function for the "composition" of the transformation in CSG, return to the world POV
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

    #Find the exit from the shape
    new_r = Ray(at(r, hit1.t + 1e-5), r.dir, 1e-5, r.tmax)
    hit2 = ray_intersection(shape, new_r)

    if hit2 === nothing
        return nothing
    end

    t_enter = hit1.t
    t_exit = hit2.t
    return (min(t_enter, t_exit), max(t_enter, t_exit)) #It returns the intervall in which the ray stays in both the shapes, so in the intersection of them

end

"""
function _difference_intervals(a::Tuple, b::Tuple)
    This function calculates the actual intervals in which the ray stays in a difference between two shapes
"""
function _difference_intervals(a::Tuple, b::Tuple)

    a_start, a_end = a
    b_start, b_end = b

    result = []

    if b_end <= a_start || b_start >= a_end
        push!(result, a)
    else
        if b_start > a_start
            push!(result, (a_start, min(b_start, a_end)))
        end
        if b_end < a_end
            push!(result, (max(b_end, a_start), a_end))
        end
    end

    return result

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

    function union_shape(s1, s2, T::Transformation=Transformation(Matrix{Float64}(I(4))))
        new(s1, s2, T)
    end

end

"""
function ray_intersection(u_shape::union_shape, r::Ray)
    Given a union of shapes and a ray, it returns the HitRecord for the first intersection between the ray and the shapes's union
"""
function ray_intersection(u_shape::union_shape, r::Ray)

    inv_r = inverse(u_shape.T)(r)

    i1 = _ray_interval(u_shape.s1, inv_r)
    i2 = _ray_interval(u_shape.s2, inv_r)

    if i1 === nothing && i2 === nothing
        return nothing
    elseif i1 === nothing
        t_enter = i2[1]
        point_hit = at(inv_r, t_enter)
        hit_shape = u_shape.s2
    elseif i2 === nothing
        t_enter = i1[1]
        point_hit = at(inv_r, t_enter)
        hit_shape = u_shape.s1
    else
        t_enter1, t_exit1 = i1
        t_enter2, t_exit2 = i2

        if t_exit1 ≥ t_enter2 || t_exit2 ≥ t_enter1
            t_enter = min(t_enter1, t_enter2)
            hit_shape = t_enter == t_enter1 ? u_shape.s1 : u_shape.s2
        else
            if t_enter1 < t_enter2
                t_enter = t_enter1
                hit_shape = u_shape.s1
            else
                t_enter = t_enter2
                hit_shape = u_shape.s2
            end
        end

        point_hit = at(inv_r, t_enter)
    end

    normal = _shape_normal(hit_shape, inv_r, point_hit)

    return HitRecord(
        u_shape.T(point_hit),
        u_shape.T(normal),
        _xyz_to_uv(point_hit),
        t_enter,
        r
    )

end

#INTERSECTION
"""
new shape type for intersection in CSG:
- s1::Shape --> first shape (in this case order counts)
- s2::Shape --> second shape
- T::Transformation --> applied transformation
"""
struct intersec_shape <: Shape

    s1::Shape
    s2::Shape
    T::Transformation

    function intersec_shape(s1::Shape, s2::Shape, T::Transformation=Transformation(Matrix{Float64}(I(4))))
        new(s1, s2, T)
    end

end

"""
function ray_intersection(i_shape::intersec_shape, r::Ray)
    given a n intersection of shapes and a ray, it returns the HitRecord for the first intersection between the ray and the shapes's intersection
"""
function ray_intersection(i_shape::intersec_shape, r::Ray)

    #Transforms the ray in the shapes's space
    inv_r = inverse(i_shape.T)(r)

    interval1 = _ray_interval(i_shape.s1, inv_r)
    interval2 = _ray_interval(i_shape.s2, inv_r)

    if interval1 === nothing || interval2 === nothing
        return nothing
    end

    t_enter1, t_exit1 = interval1
    t_enter2, t_exit2 = interval2

    t_enter = max(t_enter1, t_enter2)
    t_exit  = min(t_exit1, t_exit2)

    if t_enter >= t_exit
        return nothing
    end

    #The shape that cause the t_enter is the one with that same t_enter
    hit_shape = t_enter == t_enter1 ? i_shape.s1 : i_shape.s2

    point_hit = at(inv_r, t_enter)
    normal = _shape_normal(hit_shape, inv_r, point_hit)

    return HitRecord(
        i_shape.T(point_hit),
        i_shape.T(normal),
        _xyz_to_uv(point_hit),
        t_enter,
        r
    )

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

    function diff_shape(s1::Shape, s2::Shape, T::Transformation=Transformation(Matrix{Float64}(I(4))))
        new(s1, s2, T)
    end

end

"""
function ray_intersection(d_shape::diff_shape, r::Ray)
    given a difference of shapes and a ray, it returns the HitRecord for the first intersection between the ray and the shapes's difference
"""
function ray_intersection(d_shape::diff_shape, r::Ray)

    inv_r = inverse(d_shape.T)(r)

    intA = _ray_interval(d_shape.s1, inv_r)
    intB = _ray_interval(d_shape.s2, inv_r)

    if intA === nothing
        return nothing
    end

    #Evaluates the intervals difference
    intervals = if intB === nothing
        [intA]
    else
        _difference_intervals(intB, intA)
    end

    if isempty(intervals)
        return nothing
    end

    t_hit = intervals[1][1]
    point_hit = at(inv_r, t_hit)

    normal = _shape_normal(d_shape.s1, inv_r, point_hit)

    return HitRecord(
        d_shape.T(point_hit),
        d_shape.T(normal),
        _xyz_to_uv(point_hit),
        t_hit,
        r
    )

end

#=
"""
function Base.:+(s1::Shape, s2::Shape, T::Transformation=Transformation(Matrix{Float64}(I(4))))
    sums two shapes returning a union_shape
"""
function Base.:+(s1::Shape, s2::Shape, T::Transformation=Transformation(Matrix{Float64}(I(4))))
    return union_shape(s1, s2, T)
end

"""
function Base.:-(s1::Shape, s2::Shape, T::Transformation=Transformation(Matrix{Float64}(I(4))))
    subtracts two shapes returning a diff_shape
"""
function Base.:-(s1::Shape, s2::Shape, T::Transformation=Transformation(Matrix{Float64}(I(4))))
    return diff_shape(s1, s2, T)
end

"""
function Base.:^(s1::Shape, s2::Shape, T::Transformation=Transformation(Matrix{Float64}(I(4))))
    intersecates two shapes returning a intersec_shape
"""
function Base.:^(s1::Shape, s2::Shape, T::Transformation=Transformation(Matrix{Float64}(I(4))))
    return intersec_shape(s1, s2, T)
end
=#
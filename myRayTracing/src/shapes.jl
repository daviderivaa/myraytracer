#SHAPE STRUCTS
using LinearAlgebra

#DEFINING AN ABSTRACT TYPE FOR SHAPES
"""Abstract struct for shapes"""
abstract type Shape
end

"""Abstract method for ray_intersection"""
function ray_intersection(shape::Shape, r::Ray)
    throw(Type_error("ray_intersection method not implemented for $(typeof(shape))"))
end

"""Abstract method for quick_ray_intersection"""
function quick_ray_intersection(shape::Shape, r::Ray)
    throw(Type_error("quick_ray_intersection method not implemented for $(typeof(shape))"))
end

"""Abstract method for normals"""
function _shape_normal(shape::Shape, r::Ray, p::Point)
    throw(Type_error("_shape_normal method not implemented for $(typeof(shape))"))
end

"""Abstract method for (u,v) coordinates"""
function _xyz_to_uv(shape::Shape, p::Point)
    throw(Type_error("_shape_normal method not implemented for $(typeof(shape))"))
end

#DEFINING SUBSTRUCTS
#SPHERE STRUCT
"""
struct Sphere <: Shape
    Creates a 3D unit sphere centered in the origin of the axes. 

    T::Transformation --> The transformation applied to the unit sphere in the origin to re-scale it 
                            (eventually transforming it into an ellipsoid) and translate it in the right location
    material::Material --> The material of the shape

"""
struct Sphere <: Shape

    T::Transformation
    material::Material

    function Sphere(T::Transformation=Transformation(Matrix{Float64}(I(4))), material::Material=Material())
        new(T, material)
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
function _xyz_to_uv(s::Sphere, p::Point)
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
                      (_xyz_to_uv(shape, point_hit)), #(u,v) vec hitted on the surface
                      t_hit, #t
                      r, #ray
                      shape #s
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

    T::Transformation --> The transformation applied to the plane to rotate it and translate it in the right location.
    material::Material --> The material of the shape

"""
struct Plane <: Shape

    T::Transformation
    material::Material

    function Plane(T::Transformation=Transformation(Matrix{Float64}(I(4))), material::Material=Material())
        new(T, material)
    end

end

"""
function _shape_normal(pl, r, p::Point = nothing)
    it returns the normal to the plane x-y, chosen in order to have the opposite direction of the incoming ray
"""
function _shape_normal(pl::Plane, r::Ray, p::Point)
    if (r.dir.z) >= 0
        return Normal(0.0, 0.0, -1.0)
    else
        return Normal(0.0, 0.0, 1.0)
    end
end

"""
function _xyz_to _uv(p)
    given a point on the x-y plane, in returns its (u,v) 2D form
"""
function _xyz_to_uv(s::Plane, p::Point)
    u = p.x - floor(p.x)
    v = p.y - floor(p.y)
    return Vec2d(u, v)
end

"""
function ray_intersection(shape, r)
    given a plane and a ray, it returns the HitRecord for the intersection between the ray and the plane
"""
function ray_intersection(shape::Plane, r::Ray)

    inv_r = inverse(shape.T)(r)

    if inv_r.dir.z == 0
        return nothing
    end
 
    t_hit = - inv_r.origin.z / inv_r.dir.z

    if t_hit < inv_r.tmin || t_hit > inv_r.tmax
        return nothing
    end
    
    point_hit = at(inv_r, t_hit)

    return HitRecord( (shape.T)(point_hit), #hitted point in the world
                      (shape.T)(_shape_normal(shape, inv_r, point_hit)), #normal at the surface in the world
                      (_xyz_to_uv(shape, point_hit)), #(u,v) vec hitted on the surface
                      t_hit, #t
                      r, #ray
                      shape #s
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

#RECTANGLE STRUCT
"""
struct Rectangle <: Shape
    Creates a Rectangle

    origin::Point --> first vertex
    edge1::Vec --> first vectorial edge
    edge2::Vec --> second vectorial edge
    normal::Normal --> Normal vector to the rectangle's plane
    material::Material --> the material of the rectangle
    T::Transformation --> global transformation

    function Rectangle(origin::Point, edge1::Vec, edge2::Vec, T::Transformation, material::Material=Material())
        n = normalize(cross(edge1, edge2)) |> Normal
        new(origin, edge1, edge2, n, T, material)
    end
end
"""
struct Rectangle <: Shape
    origin::Point
    edge1::Vec
    edge2::Vec
    normal::Normal
    T::Transformation
    material::Material

    function Rectangle(origin::Point, edge1::Vec, edge2::Vec, T::Transformation=Transformation(Matrix{Float64}(I(4))), material::Material=Material())
        n = Vec_to_Normal(normalize(cross(edge1, edge2)))
        new(origin, edge1, edge2, n, T, material)
    end
end

"""
function _shape_normal(rect, r, p::Point = nothing)
    it returns the normal to a rectangle, chosen in order to have the opposite direction of the incoming ray
"""
function _shape_normal(rect::Rectangle, r::Ray, p::Point)
    if (rect.normal * r.dir) < 0
        return rect.normal
    else
        return neg(rect.normal)
    end
end

"""
function ray_intersection(shape, r)
    given a plane and a ray, it returns the HitRecord for the intersection between the ray and the sphere
"""
function ray_intersection(rect::Rectangle, r::Ray)

    inv_r = inverse(rect.T)(r)

    denom = rect.normal * inv_r.dir
    if abs(denom) < 1e-8
        return nothing
    end

    d = rect.normal * Point_to_Vec(rect.origin)
    t_hit = (d - (rect.normal * Point_to_Vec(inv_r.origin))) / denom

    if t_hit < inv_r.tmin || t_hit > inv_r.tmax
        return nothing
    end

    p_hit = at(inv_r, t_hit)

    v = p_hit - rect.origin

    u = (v * rect.edge1) / squared_norm(rect.edge1)
    v_ = (v * rect.edge2) / squared_norm(rect.edge2)

    if u < 0 || u > 1 || v_ < 0 || v_ > 1
        return nothing
    end

    uv = Vec2d(u, v_)

    return HitRecord(
        rect.T(p_hit),
        rect.T(_shape_normal(rect, inv_r, p_hit)),
        uv,
        t_hit,
        r,
        rect
    )

end

"""
function quick_ray_intersection(shape, r)
    given a rectangle and a ray, it returns true/false if there is/isn't intersection
"""
function quick_ray_intersection(rect::Rectangle, r::Ray)

    inv_r = inverse(rect.T)(r)

    denom = dot(rect.normal, inv_r.dir)
    if abs(denom) < 1e-8
        return false
    end

    d = dot(rect.normal, Point_to_Vec(rect.origin))
    t_hit = (d - dot(rect.normal, Point_to_Vec(inv_r.origin))) / denom

    if t_hit < inv_r.tmin || t_hit > inv_r.tmax
        return false
    end

    p_hit = at(inv_r, t_hit)
    v = Point_to_Vec(p_hit - rect.origin)

    u = dot(v, rect.edge1) / squared_norm(rect.edge1)
    v_ = dot(v, rect.edge2) / squared_norm(rect.edge2)

    return 0 <= u <= 1 && 0 <= v_ <= 1

end

###############################################################à

#BOX STRUCT
"""
struct Box <: Shape
    Creates a box. It has a vertex in the origin and the edges aligned with the xyz axes.

    X::Float64 --> lenght of x-aligned edges
    Y::Float64 --> lenght of y-aligned edges
    Z::Float64 --> lenght of z-aligned edges
    T::Transformation --> The transformation applied to the box
    material::Material --> the material of the box

    function Box(X::Float64, Y::Float64, Z::Float64, T::Transformation, material::Material=Material())
        new(X, Y, Z, T, material)
    end
end
"""
struct Box <: Shape
 
    X::Float64
    Y::Float64
    Z::Float64
    T::Transformation
    material::Material

    function Box(X::Float64, Y::Float64, Z::Float64, T::Transformation=Transformation(Matrix{Float64}(I(4))), material::Material=Material())
        new(X, Y, Z, T, material)
    end
end

"""
function _shape_normal(box, r, p::Point)
    it returns the normal to the box, depending of the hitten face, chosen in order to have the opposite direction of the incoming ray
"""
function _shape_normal(box::Box, r::Ray, p::Point)
    epsilon=1e-6
    if abs(p.x-0.0) < epsilon || abs(p.x - box.X) < epsilon
        if sign(r.dir.x) != 0
            return Normal(-sign(r.dir.x), 0.0, 0.0) 
        end
    elseif abs(p.y-0.0) < epsilon || abs(p.y - box.Y) < epsilon
        if sign(r.dir.y) != 0
            return Normal(0.0, -sign(r.dir.y), 0.0)
        end
    elseif abs(p.z-0.0) < epsilon || abs(p.z - box.Z) < epsilon
        if sign(r.dir.z) != 0
            return Normal(0.0, 0.0, -sign(r.dir.z))
        end
    end
end

"""
function _xyz_to _uv(box, p)
    given a point on the box, in returns its (u,v) 2D form
"""
function _xyz_to_uv(box::Box, p::Point)
    epsilon=1e-6
    if abs(p.x-0.0) < epsilon || abs(p.x - box.X) < epsilon
        return Vec2d(p.y/box.Y, p.z/box.Z)
    elseif abs(p.y-0.0) < epsilon || abs(p.y - box.Y) < epsilon
        return Vec2d(p.x/box.X, p.z/box.Z)
    elseif abs(p.z-0.0) < epsilon || abs(p.z - box.Z) < epsilon
        return Vec2d(p.x/box.X, p.y/box.Y)
    end
end

"""
function ray_intersection(box, r)
    given a box and a ray, it returns the HitRecord for the intersection between the ray and the box
"""
function ray_intersection(box::Box, r::Ray)

    inv_r = inverse(box.T)(r)

    if inv_r.dir.x == 0.0
        if (inv_r.origin.x < 0.0 || inv_r.origin.x > box.X)
            return nothing
        else
            int_x = (-Inf,Inf)
        end
    else
        int_x = (min(-inv_r.origin.x/inv_r.dir.x,(box.X-inv_r.origin.x)/inv_r.dir.x), 
                 max(-inv_r.origin.x/inv_r.dir.x,(box.X-inv_r.origin.x)/inv_r.dir.x))
    end


    if inv_r.dir.y == 0.0
        if (inv_r.origin.y < 0.0 || inv_r.origin.y > box.Y)
            return nothing
        else
            int_y = (-Inf,Inf)
        end
    else
        int_y = (min(-inv_r.origin.y/inv_r.dir.y,(box.Y-inv_r.origin.y)/inv_r.dir.y), 
                 max(-inv_r.origin.y/inv_r.dir.y,(box.Y-inv_r.origin.y)/inv_r.dir.y))
    end


    if inv_r.dir.z == 0.0
        if (inv_r.origin.z < 0.0 || inv_r.origin.z > box.Z)
            return nothing
        else
            int_z = (-Inf,Inf)
        end
    else
        int_z = (min(-inv_r.origin.z/inv_r.dir.z,(box.Z-inv_r.origin.z)/inv_r.dir.z), 
                 max(-inv_r.origin.z/inv_r.dir.z,(box.Z-inv_r.origin.z)/inv_r.dir.z))
    end

    t_1 = max(int_x[1], int_y[1], int_z[1])
    t_2 = min(int_x[2], int_y[2], int_z[2])

    if t_1 > t_2
        return nothing
    end

    if (t_1 > inv_r.tmin) && (t_1 < inv_r.tmax)
        t_hit = t_1
    elseif (t_2 > inv_r.tmin) && (t_2 < inv_r.tmax)
        t_hit = t_2
    else
        return nothing
    end

    point_hit = at(inv_r, t_hit)

    return HitRecord( box.T(point_hit), #hitted point in the world
                      box.T(_shape_normal(box, inv_r, point_hit)), #normal at the surface in the world
                      (_xyz_to_uv(box, point_hit)), #(u,v) vec hitted on the surface
                      t_hit, #t
                      r, #ray
                      box #s
                    )

end

"""
function quick_ray_intersection(box, r)
    given a box and a ray, it returns whether the intersection between the ray and the box happens or not
"""
function quick_ray_intersection(box::Box, r::Ray)

    inv_r = inverse(box.T)(r)

    if inv_r.dir.x == 0.0
        if (inv_r.origin.x < 0.0 || inv_r.origin.x > box.X)
            return false
        else
            int_x = (-Inf,Inf)
        end
    else
        int_x = (min(-inv_r.origin.x/inv_r.dir.x,(box.X-inv_r.origin.x)/inv_r.dir.x), 
                 max(-inv_r.origin.x/inv_r.dir.x,(box.X-inv_r.origin.x)/inv_r.dir.x))
    end


    if inv_r.dir.y == 0.0
        if (inv_r.origin.y < 0.0 || inv_r.origin.y > box.Y)
            return false
        else
            int_y = (-Inf,Inf)
        end
    else
        int_y = (min(-inv_r.origin.y/inv_r.dir.y,(box.Y-inv_r.origin.y)/inv_r.dir.y), 
                 max(-inv_r.origin.y/inv_r.dir.y,(box.Y-inv_r.origin.y)/inv_r.dir.y))
    end


    if inv_r.dir.z == 0.0
        if (inv_r.origin.z < 0.0 || inv_r.origin.z > box.Z)
            return false
        else
            int_z = (-Inf,Inf)
        end
    else
        int_z = (min(-inv_r.origin.z/inv_r.dir.z,(box.Z-inv_r.origin.z)/inv_r.dir.z), 
                 max(-inv_r.origin.z/inv_r.dir.z,(box.Z-inv_r.origin.z)/inv_r.dir.z))
    end

    t_1 = max(int_x[1], int_y[1], int_z[1])
    t_2 = min(int_x[2], int_y[2], int_z[2])

    if ((t_1 > inv_r.tmin) && (t_1 < inv_r.tmax)) || ((t_2 > inv_r.tmin) && (t_2 < inv_r.tmax))
        true  
    else
        return false
    end
end


#HIT RECORD STRUCT

"""
Defining HitRecord struct and methods

    world_point::Point --> 3D point where the intersection occurred
    normal::Normal --> surface normal vector
    surface_point::Vec2d --> coordinates of the intersection
    t::Float64 --> parameter associated with the intersection
    ray::Ray --> light ray that caused the intersection
    s::Shape --> shape intersected
"""
mutable struct HitRecord

    world_point::Point
    normal::Normal
    surface_point::Vec2d
    t::Float64
    ray::Ray
    s::Shape

    function HitRecord(p::Point, n::Normal, surf_p::Vec2d, t, r::Ray, s::Shape)
        new(p, n, surf_p, t, r, s)
    end

end

function is_close(HR1::HitRecord, HR2::HitRecord, epsilon=1e-5)

    """Check whether two `HitRecord` represent the same hit event or not"""
    return ( is_close(HR1.world_point, HR2.world_point, epsilon) &&
    is_close(HR1.normal, HR2.normal, epsilon) &&
    is_close(HR1.surface_point, HR2.surface_point, epsilon) &&
    abs(HR1.t - HR2.t) < epsilon &&
    is_close(HR1.ray, HR2.ray, epsilon))

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
        hit.ray,
        hit.s
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
    new_origin = at(r, hit1.t + 1e-8)
    new_r = Ray(new_origin, r.dir, 0.0, r.tmax)
    hit2 = ray_intersection(shape, new_r)

    if hit2 === nothing
        return nothing
    end

    t_enter = hit1.t
    t_exit = hit1.t + hit2.t
    return (min(t_enter, t_exit), max(t_enter, t_exit)) #It returns the intervall in which the ray stays in the shape

end

"""
function _difference_hit(a::Tuple, b::Tuple)
    This function calculates the actual shape hit in a difference
"""
function _difference_hit(a::Tuple, b::Tuple)

    a_start, a_end = a
    b_start, b_end = b

    if b_end <= a_start || b_start >= a_end
        return a_start
    else
        if b_start > a_start
            return a_start
        else
            if b_end < a_end
                return b_end
            else
                return nothing
            end
        end
    end

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

    hit1 = ray_intersection(u_shape.s1, inv_r)
    hit2 = ray_intersection(u_shape.s2, inv_r)

    if hit1 === nothing && hit2 === nothing
        return nothing
    end

    if hit1 === nothing
        chosen_hit = hit2
        hit_shape = u_shape.s2
    elseif hit2 === nothing
        chosen_hit = hit1
        hit_shape = u_shape.s1
    else
        if hit1.t < hit2.t
            chosen_hit = hit1
            hit_shape = u_shape.s1
        else
            chosen_hit = hit2
            hit_shape = u_shape.s2
        end
    end

    point_hit = at(inv_r, chosen_hit.t)
    normal = _shape_normal(hit_shape, inverse(hit_shape.T)(inv_r), inverse(hit_shape.T)(point_hit))

    return HitRecord(
        u_shape.T(point_hit),
        u_shape.T(normal),
        _xyz_to_uv(hit_shape, inverse(hit_shape.T)(point_hit)),
        chosen_hit.t,
        r,
        hit_shape
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
    normal = _shape_normal(hit_shape, inverse(hit_shape.T)(inv_r), inverse(hit_shape.T)(point_hit))

    return HitRecord(
        i_shape.T(point_hit),
        i_shape.T(normal),
        _xyz_to_uv(hit_shape, inverse(hit_shape.T)(point_hit)),
        t_enter,
        r,
        hit_shape
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
    if intA === nothing
        return nothing
    end

    t_enter1 = intA[1]

    intB = _ray_interval(d_shape.s2, inv_r)

    t_hit = intB === nothing ? t_enter1 : _difference_hit(intA, intB)

    if t_hit === nothing
        return nothing
    end

    point_hit = at(inv_r, t_hit)

    hit_shape = isapprox(t_hit, t_enter1; atol=1e-6) ? d_shape.s1 : d_shape.s2

    normal = _shape_normal(hit_shape, inverse(hit_shape.T)(inv_r), inverse(hit_shape.T)(point_hit))

    if hit_shape == d_shape.s1
        return HitRecord(
            d_shape.T(point_hit),
            d_shape.T(normal),
            _xyz_to_uv(hit_shape, inverse(hit_shape.T)(point_hit)),
            t_hit,
            r,
            hit_shape
        )
    else
        return HitRecord(
            d_shape.T(point_hit),
            d_shape.T(normal),
            _xyz_to_uv(hit_shape, inverse(hit_shape.T)(point_hit)),
            t_hit,
            r,
            hit_shape
        )
    end

end
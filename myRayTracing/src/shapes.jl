#SHAPE STRUCTS

#DEFINING AN ABSTRACT TYPE FOR SHAPES
"""Abstract struct for shapes"""
abstract type Shape
end

"""Abstract method for all_ray_intersection"""
function all_ray_intersection(shape::Shape, r::Ray)
    throw(Type_error("all_ray_intersection method not implemented for $(typeof(shape))"))
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
function all_ray_intersection(shape, r)
    given a sphere and a ray, it returns the HitRecords for all the intersections between the ray and the sphere
"""
function all_ray_intersection(shape::Sphere, r::Ray)
    hits = Vector{Tuple{HitRecord, HitRecord}}()

    inv_r = inverse(shape.T)(r)
    o_vec = Point_to_Vec(inv_r.origin)

    a = squared_norm(inv_r.dir)
    b = o_vec * inv_r.dir #tecnically is b/2, but we will use delta/4
    c = squared_norm(o_vec) - 1
    delta = b*b - a*c #it's delta/4

    if delta <= 0
        return hits
    end
 
    sqrt_delta = √(delta)

    t_1 = ( -b - sqrt_delta ) / a
    t_2 = ( -b + sqrt_delta ) / a

    if t_1 < inv_r.tmax
        point_hit_1 = at(inv_r, t_1)
        hit_1 = HitRecord(shape.T(point_hit_1), #hitted point in the world
                          shape.T(_shape_normal(shape, inv_r, point_hit_1)), #normal at the surface in the world
                          (_xyz_to_uv(shape, point_hit_1)), #(u,v) vec hitted on the surface
                          t_1, #t
                          r, #ray
                          shape #sphere
                          )
            
    end

    if t_2 < inv_r.tmax
        point_hit_2 = at(inv_r, t_2)
        hit_2 = HitRecord(shape.T(point_hit_2), #hitted point in the world
                          shape.T(_shape_normal(shape, inv_r, point_hit_2)), #normal at the surface in the world
                          (_xyz_to_uv(shape, point_hit_2)), #(u,v) vec hitted on the surface
                          t_2, #t
                          r, #ray
                          shape #sphere
                          )
    end
    
    push!(hits, (hit_1, hit_2))

    return hits

end

"""
function ray_intersection(shape, r)
    given a sphere and a ray, it returns the HitRecord for the first intersection between the ray and the sphere
"""
function ray_intersection(shape::Sphere, r::Ray)
    all_hits = all_ray_intersection(shape, r)

    if !isempty(all_hits)
        first_hit_index = findfirst(hit -> hit.t > r.tmin, all_hits[1])

        if first_hit_index !== nothing
            return all_hits[1][first_hit_index]
        else
            return nothing
        end 
    else
        return nothing
    end
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

    if abs(inv_r.dir.z) < 1e-6
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

    if abs(inv_r.dir.z) < 1e-6
        return false
    else 
        t_hit = - inv_r.origin.z / inv_r.dir.z
        if t_hit < inv_r.tmin || t_hit > inv_r.tmax
            return false
        else
            return true
        end
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
        if X <= 0.0 || Y <= 0.0 || Z <= 0.0
            throw(ArgumentError("Box.X, .Y and .Z must be positives"))
        end
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
function all_ray_intersection(box, r)
    given a box and a ray, it returns all the HitRecords for the intersection between the ray and the box
"""
function all_ray_intersection(box::Box, r::Ray)
    hits = Vector{Tuple{HitRecord, HitRecord}}()

    inv_r = inverse(box.T)(r)

    if abs(inv_r.dir.x) < 1e-6
        if (inv_r.origin.x < 0.0 || inv_r.origin.x > box.X)
            return hits
        else
            int_x = (-Inf,Inf)
        end
    else
        int_x = (min(-inv_r.origin.x/inv_r.dir.x,(box.X-inv_r.origin.x)/inv_r.dir.x), 
                 max(-inv_r.origin.x/inv_r.dir.x,(box.X-inv_r.origin.x)/inv_r.dir.x))
    end


    if abs(inv_r.dir.y) < 1e-6
        if (inv_r.origin.y < 0.0 || inv_r.origin.y > box.Y)
            return hits
        else
            int_y = (-Inf,Inf)
        end
    else
        int_y = (min(-inv_r.origin.y/inv_r.dir.y,(box.Y-inv_r.origin.y)/inv_r.dir.y), 
                 max(-inv_r.origin.y/inv_r.dir.y,(box.Y-inv_r.origin.y)/inv_r.dir.y))
    end


    if abs(inv_r.dir.z) < 1e-6
        if (inv_r.origin.z < 0.0 || inv_r.origin.z > box.Z)
            return hits
        else
            int_z = (-Inf,Inf)
        end
    else
        int_z = (min(-inv_r.origin.z/inv_r.dir.z,(box.Z-inv_r.origin.z)/inv_r.dir.z), 
                 max(-inv_r.origin.z/inv_r.dir.z,(box.Z-inv_r.origin.z)/inv_r.dir.z))
    end

    t_1 = max(int_x[1], int_y[1], int_z[1])
    t_2 = min(int_x[2], int_y[2], int_z[2])

    if (t_2-t_1) < 1e-6 #check both t2>=t1 and t2!=t1
        return hits
    end

    if t_1 < inv_r.tmax
        point_hit_1 = at(inv_r, t_1)
        hit_1 = HitRecord(box.T(point_hit_1), #hitted point in the world
                          box.T(_shape_normal(box, inv_r, point_hit_1)), #normal at the surface in the world
                          (_xyz_to_uv(box, point_hit_1)), #(u,v) vec hitted on the surface
                          t_1, #t
                          r, #ray
                          box #box
                          )
    
    end

    if t_2 < inv_r.tmax
        point_hit_2 = at(inv_r, t_2)
        hit_2 = HitRecord(box.T(point_hit_2), #hitted point in the world
                          box.T(_shape_normal(box, inv_r, point_hit_2)), #normal at the surface in the world
                          (_xyz_to_uv(box, point_hit_2)), #(u,v) vec hitted on the surface
                          t_2, #t
                          r, #ray
                          box #box
                          )
             
    end
    
    push!(hits, (hit_1, hit_2))

    return hits

end

"""
function ray_intersection(box, r)
    given a box and a ray, it returns the HitRecord for the first intersection between the ray and the box
"""
function ray_intersection(box::Box, r::Ray)
    all_hits = all_ray_intersection(box, r)

    if !isempty(all_hits)
        first_hit_index = findfirst(hit -> hit.t > r.tmin, all_hits[1])

        if first_hit_index !== nothing
            return all_hits[1][first_hit_index]
        else
            return nothing
        end 
    else
        return nothing
    end
end

"""
function quick_ray_intersection(box, r)
    given a box and a ray, it returns whether the intersection between the ray and the box happens or not
"""
function quick_ray_intersection(box::Box, r::Ray)

    inv_r = inverse(box.T)(r)

    if abs(inv_r.dir.x) < 1e-6
        if (inv_r.origin.x < 0.0 || inv_r.origin.x > box.X)
            return false
        else
            int_x = (-Inf,Inf)
        end
    else
        int_x = (min(-inv_r.origin.x/inv_r.dir.x,(box.X-inv_r.origin.x)/inv_r.dir.x), 
                 max(-inv_r.origin.x/inv_r.dir.x,(box.X-inv_r.origin.x)/inv_r.dir.x))
    end


    if abs(inv_r.dir.y) < 1e-6
        if (inv_r.origin.y < 0.0 || inv_r.origin.y > box.Y)
            return false
        else
            int_y = (-Inf,Inf)
        end
    else
        int_y = (min(-inv_r.origin.y/inv_r.dir.y,(box.Y-inv_r.origin.y)/inv_r.dir.y), 
                 max(-inv_r.origin.y/inv_r.dir.y,(box.Y-inv_r.origin.y)/inv_r.dir.y))
    end


    if abs(inv_r.dir.z) < 1e-6
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

    if ((t_2-t_1) > 1e-6) && ( ((t_1 > inv_r.tmin) && (t_1 < inv_r.tmax)) || ((t_2 > inv_r.tmin) && (t_2 < inv_r.tmax)) )
        return true  
    else
        return false
    end
end


####################################################################################################

#CYLINDER STRUCT
"""
struct Cylinder <: Shape
    Creates a cylinder. It has a base on the xy plane centered in the origin and his axis along z axis.

    R::Float64 --> Radius of the cylinder's base
    H::Float64 --> Height of the cylinder
    T::Transformation --> The transformation applied to the cylinder
    material::Material --> the material of the cylinder

    function Cylinder(R::Float64, H::Float64, T::Transformation=Transformation(Matrix{Float64}(I(4))), material::Material=Material())
        new(R, H, T, material)
    end
end
"""
struct Cylinder <: Shape
 
    R::Float64
    H::Float64
    T::Transformation
    material::Material

    function Cylinder(R::Float64, H::Float64, T::Transformation=Transformation(Matrix{Float64}(I(4))), material::Material=Material())
        if R <= 0.0 || H <= 0.0
            throw(ArgumentError("Cylinder's Radius and Height must be positives"))
        end
        new(R, H, T, material)
    end
end

"""
function _shape_normal(cyl, p, r)
    it returns the normal to the cylinder surface in a given point, chosen in order to have the opposite direction of the incoming ray.
"""
function _shape_normal(cyl::Cylinder, r::Ray, p::Point)
    epsilon = 1e-6

    if abs(p.z - 0.0) < epsilon || abs(p.z - cyl.H) < epsilon
        n = Normal(0.0, 0.0, 1.0)
    else
        n = normalize(Normal(p.x, p.y, 0.0))
    end

    if (n * r.dir) < 0
        return n
    else
        return neg(n)
    end
end

"""
function _xyz_to_uv(cyl, p)
    given a point on the cylinder, it returns its (u,v) 2D form.
"""
function _xyz_to_uv(cyl::Cylinder, p::Point)
    epsilon = 1e-6 

    if abs(p.z - 0.0) < epsilon || abs(p.z - cyl.H) < epsilon
        u = (p.x + cyl.R) / (2 * cyl.R)
        v = (p.y + cyl.R) / (2 * cyl.R)
    else
        u = ( atan(p.y, p.x) + π ) / (2π)
        v = p.z / cyl.H 
    end
    return Vec2d(u, v)
end

"""
function all_ray_intersection(cyl, r)
    given a cylinder and a ray, it returns all the HitRecords for the intersection between the ray and the cylinder
"""
function all_ray_intersection(cyl::Cylinder, r::Ray)
    hits = Vector{Tuple{HitRecord, HitRecord}}()

    inv_r = inverse(cyl.T)(r)

    if abs(inv_r.dir.x) < 1e-6 && abs(inv_r.dir.y) < 1e-6
        if √(inv_r.origin.x^2 + inv_r.origin.y^2) >= cyl.R
            return hits
        else
            int_xy = (-Inf,Inf)
        end
    else
        a = inv_r.dir.x^2 + inv_r.dir.y^2
        b = inv_r.origin.x * inv_r.dir.x + inv_r.origin.y * inv_r.dir.y #tecnically is b/2, but we will use delta/4
        c = inv_r.origin.x^2 + inv_r.origin.y^2 - cyl.R^2
        delta = b*b - a*c #it's delta/4
        if delta <= 0
            return hits
        else
            sqrt_delta = √(delta)
            int_xy = ( (-b-sqrt_delta)/a , (-b+sqrt_delta)/a)
        end
    end

    if abs(inv_r.dir.z) < 1e-6
        if (inv_r.origin.z < 0.0 || inv_r.origin.z > cyl.H)
            return hits
        else
            int_z = (-Inf,Inf)
        end
    else
        int_z = (min(-inv_r.origin.z/inv_r.dir.z,(cyl.H-inv_r.origin.z)/inv_r.dir.z), 
                 max(-inv_r.origin.z/inv_r.dir.z,(cyl.H-inv_r.origin.z)/inv_r.dir.z))
    end

    t_1 = max(int_xy[1], int_z[1])
    t_2 = min(int_xy[2], int_z[2])

    if (t_2-t_1) < 1e-6 #check both t2>=t1 and t2!=t1
        return hits
    end

    if t_1 < inv_r.tmax
        point_hit_1 = at(inv_r, t_1)
        hit_1 = HitRecord(cyl.T(point_hit_1), #hitted point in the world
                          cyl.T(_shape_normal(cyl, inv_r, point_hit_1)), #normal at the surface in the world
                          (_xyz_to_uv(cyl, point_hit_1)), #(u,v) vec hitted on the surface
                          t_1, #t
                          r, #ray
                          cyl #cylinder
                          )
    
    end

    if t_2 < inv_r.tmax
        point_hit_2 = at(inv_r, t_2)
        hit_2 = HitRecord(cyl.T(point_hit_2), #hitted point in the world
                          cyl.T(_shape_normal(cyl, inv_r, point_hit_2)), #normal at the surface in the world
                          (_xyz_to_uv(cyl, point_hit_2)), #(u,v) vec hitted on the surface
                          t_2, #t
                          r, #ray
                          cyl #cylinder
                          )
             
    end
    
    push!(hits, (hit_1, hit_2))

    return hits

end

"""
function ray_intersection(cyl, r)
    given a cylinder and a ray, it returns the HitRecord for the first intersection between the cylinder and the box
"""
function ray_intersection(cyl::Cylinder, r::Ray)
    all_hits = all_ray_intersection(cyl, r)

    if !isempty(all_hits)
        first_hit_index = findfirst(hit -> hit.t > r.tmin, all_hits[1])

        if first_hit_index !== nothing
            return all_hits[1][first_hit_index]
        else
            return nothing
        end 
    else
        return nothing
    end
end

"""
function quick_ray_intersection(cyl, r)
    given a cylinder and a ray, it returns whether the intersection between the ray and the ray and the cylinder happens or not
"""
function quick_ray_intersection(cyl::Cylinder, r::Ray)
    inv_r = inverse(cyl.T)(r)

    if abs(inv_r.dir.x) < 1e-6 && abs(inv_r.dir.y) < 1e-6
        if √(inv_r.dir.x^2 + inv_r.dir.y^2) >= cyl.R
            return false
        else
            int_xy = (-Inf,Inf)
        end
    else
        a = inv_r.dir.x^2 + inv_r.dir.y^2
        b = inv_r.origin.x * inv_r.dir.x + inv_r.origin.y * inv_r.dir.y #tecnically is b/2, but we will use delta/4
        c = inv_r.origin.x^2 + inv_r.origin.y^2 - cyl.R^2
        delta = b*b - a*c #it's delta/4
        if delta <= 0
            return false
        else
            sqrt_delta = √(delta)
            int_xy = ( (-b-sqrt_delta)/a , (-b+sqrt_delta)/a)
        end
    end

    if abs(inv_r.dir.z) < 1e-6
        if (inv_r.origin.z < 0.0 || inv_r.origin.z > cyl.H)
            return false
        else
            int_z = (-Inf,Inf)
        end
    else
        int_z = (min(-inv_r.origin.z/inv_r.dir.z,(cyl.H-inv_r.origin.z)/inv_r.dir.z), 
                 max(-inv_r.origin.z/inv_r.dir.z,(cyl.H-inv_r.origin.z)/inv_r.dir.z))
    end

    t_1 = max(int_xy[1], int_z[1])
    t_2 = min(int_xy[2], int_z[2])

    if ((t_2-t_1) > 1e-6) && ( ((t_1 > inv_r.tmin) && (t_1 < inv_r.tmax)) || ((t_2 > inv_r.tmin) && (t_2 < inv_r.tmax)) )
        return true  
    else
        return false
    end

end

###################################################################################################
#CONE STRUCT

"""
struct Cone <: Shape
    Creates a cone. It has a base on the xy plane centered in the origin and its axis along the z axis.

    R::Float64 --> Radius of the cone's base
    H::Float64 --> Height of the cone
    T::Transformation --> The transformation applied to the cone
    material::Material --> the material of the cone

    function Cone(R::Float64, H::Float64, T::Transformation=Transformation(Matrix{Float64}(I(4))), material::Material=Material())
        new(R, H, T, material)
    end
end
"""
struct Cone <: Shape
    R::Float64
    H::Float64
    T::Transformation
    material::Material

    function Cone(R::Float64, H::Float64, T::Transformation=Transformation(Matrix{Float64}(I(4))), material::Material=Material())
        if R <= 0.0 || H <= 0.0
            throw(ArgumentError("Cone's Radius and Height must be positives"))
        end
        new(R, H, T, material)
    end
end

"""
function _shape_normal(cone, p, r)
    it returns the normal to the cone surface in a given point, chosen in order to have the opposite direction of the incoming ray.
"""
function _shape_normal(cone::Cone, r::Ray, p::Point)
    epsilon = 1e-6

    if abs(p.z) < epsilon || abs(p.z - cone.H) < epsilon
        n = Normal(0.0, 0.0, 1.0)
    else
        n = normalize(Normal(p.x, p.y, cone.R^2/cone.H * (1 - p.z/cone.H)))
    end

    if (n * r.dir) < 0
        return n
    else
        return neg(n)
    end
end

"""
function _xyz_to_uv(cone, p)
    given a point on the cone, it returns its (u,v) 2D form.
"""
function _xyz_to_uv(cone::Cone, p::Point)
    epsilon = 1e-6 

    if abs(p.z) < epsilon
        u = (p.x + cone.R) / (2 * cone.R)
        v = (p.y + cone.R) / (2 * cone.R)
    else
        u = ( atan(p.y, p.x) + π ) / (2π)
        v = p.z / cone.H 
    end
    return Vec2d(u, v)
end

"""
function all_ray_intersection(cone, r)
    given a cone and a ray, it returns all the HitRecords for the intersection between the ray and the cone
"""
function all_ray_intersection(cone::Cone, r::Ray)
    hits = Vector{Tuple{HitRecord, HitRecord}}()

    inv_r = inverse(cone.T)(r)

    if abs(inv_r.dir.x) < 1e-6 && abs(inv_r.dir.y) < 1e-6
        r_xy = √(inv_r.origin.x^2 + inv_r.origin.y^2)

        if r_xy >= cone.R
            return hits
        elseif inv_r.dir.z > 0.0
            z_hit = cone.H * (1 - r_xy/cone.R)
            int_xy = (-Inf, (z_hit-inv_r.origin.z)/inv_r.dir.z)
        else
            z_hit = cone.H * (1 - r_xy/cone.R)
            int_xy = ((z_hit-inv_r.origin.z)/inv_r.dir.z, Inf)
        end

    else

        a = inv_r.dir.x^2 + inv_r.dir.y^2 - (cone.R^2 / cone.H^2) * inv_r.dir.z^2
        b = inv_r.origin.x * inv_r.dir.x + inv_r.origin.y * inv_r.dir.y + (cone.R^2 / cone.H^2) * inv_r.dir.z * (cone.H - inv_r.origin.z) #tecnically is b/2, but we will use delta/4
        c = inv_r.origin.x^2 + inv_r.origin.y^2 - (cone.R^2 / cone.H^2) * (cone.H - inv_r.origin.z)^2  

        if abs(a) < 1e-6
            t_single_hit = - c / 2b
            test_point = at(inv_r, t_single_hit)
            if test_point.z > cone.H
                return hits
            elseif inv_r.dir.z < 0.0
                int_xy = (t_single_hit, Inf)
            else
                int_xy = (-Inf, t_single_hit)
            end        
        else

            delta = b*b - a*c #it's delta/4

            if delta <= 0
                return hits
            else
                sqrt_delta = √(delta)
                t_xy_1 = min( (-b-sqrt_delta)/a, (-b+sqrt_delta)/a )
                t_xy_2 = max( (-b-sqrt_delta)/a, (-b+sqrt_delta)/a )

                test_point_1 = at(inv_r, t_xy_1)
                test_point_2 = at(inv_r, t_xy_2)

                if test_point_1.z < cone.H
                    if test_point_2.z < cone.H
                        int_xy = (t_xy_1, t_xy_2)
                    else 
                        int_xy = (-Inf, t_xy_1)
                    end
                elseif test_point_2.z < cone.H
                    int_xy = (t_xy_2, Inf)
                else
                    return hits
                end
            end 
        end    
    end

    if abs(inv_r.dir.z) < 1e-6
        if (inv_r.origin.z < 0.0 || inv_r.origin.z > cone.H)
            return hits
        else
            int_z = (-Inf,Inf)
        end
    else
        int_z = (min(-inv_r.origin.z/inv_r.dir.z,(cone.H-inv_r.origin.z)/inv_r.dir.z), 
                 max(-inv_r.origin.z/inv_r.dir.z,(cone.H-inv_r.origin.z)/inv_r.dir.z))
    end

    t_1 = max(int_xy[1], int_z[1])
    t_2 = min(int_xy[2], int_z[2])


    if (t_2-t_1) < 1e-6 #check both t2>=t1 and t2!=t1
        return hits
    end

    if t_1 < inv_r.tmax
        point_hit_1 = at(inv_r, t_1)
        hit_1 = HitRecord(cone.T(point_hit_1), #hitted point in the world
                          cone.T(_shape_normal(cone, inv_r, point_hit_1)), #normal at the surface in the world
                          (_xyz_to_uv(cone, point_hit_1)), #(u,v) vec hitted on the surface
                          t_1, #t
                          r, #ray
                          cone #cone
                          )
    
    end

    if t_2 < inv_r.tmax
        point_hit_2 = at(inv_r, t_2)
        hit_2 = HitRecord(cone.T(point_hit_2), #hitted point in the world
                          cone.T(_shape_normal(cone, inv_r, point_hit_2)), #normal at the surface in the world
                          (_xyz_to_uv(cone, point_hit_2)), #(u,v) vec hitted on the surface
                          t_2, #t
                          r, #ray
                          cone #cone
                          )
             
    end
    
    push!(hits, (hit_1, hit_2))

    return hits

end

"""
function ray_intersection(cone, r)
    given a cone and a ray, it returns the HitRecord for the first intersection between the cone and the box
"""
function ray_intersection(cone::Cone, r::Ray)
    all_hits = all_ray_intersection(cone, r)

    if !isempty(all_hits)
        first_hit_index = findfirst(hit -> hit.t > r.tmin, all_hits[1])

        if first_hit_index !== nothing
            return all_hits[1][first_hit_index]
        else
            return nothing
        end 
    else
        return nothing
    end
end

"""
function quick_ray_intersection(cone, r)
    given a cone and a ray, it returns whether the intersection between the ray and the ray and the cone happens or not
"""
function quick_ray_intersection(cone::Cone, r::Ray)
    inv_r = inverse(cone.T)(r)

    if abs(inv_r.dir.x) < 1e-6 && abs(inv_r.dir.y) < 1e-6
        r = √(inv_r.origin.x^2 + inv_r.origin.y^2)

        if r >= cone.R
            return false
        elseif inv_r.dir.z > 0.0
            z_hit = cone.H * (1 - r/cone.R)
            int_xy = (-Inf, (z_hit-inv_r.origin.z)/inv_r.dir.z)
        else
            z_hit = cone.H * (1 - r/cone.R)
            int_xy = ((z_hit-inv_r.origin.z)/inv_r.dir.z, Inf)
        end

    else

        a = inv_r.dir.x^2 + inv_r.dir.y^2 - (cone.R^2 / cone.H^2) * inv_r.dir.z^2
        b = inv_r.origin.x * inv_r.dir.x + inv_r.origin.y * inv_r.dir.y + (cone.R^2 / cone.H^2) * inv_r.dir.z * (cone.H - inv_r.origin.z) #tecnically is b/2, but we will use delta/4
        c = inv_r.origin.x^2 + inv_r.origin.y^2 - (cone.R^2 / cone.H^2) * (cone.H - inv_r.origin.z)^2  

        if abs(a) < 1e-6
            t_single_hit = - c / b
            test_point = at(inv_r, t_single_hit)
            if test_point.z > cone.H
                return false
            elseif inv_r.dir.z < 0.0
                int_xy = (t_single_hit, Inf)
            else
                int_xy = (-Inf, t_single_hit)
            end
        end

        delta = b*b - a*c #it's delta/4

        if delta <= 0
            return false
        else
            sqrt_delta = √(delta)
            t_xy_1 = min( (-b-sqrt_delta)/a, (-b+sqrt_delta)/a )
            t_xy_2 = max( (-b-sqrt_delta)/a, (-b+sqrt_delta)/a )

            test_point_1 = at(inv_r, t_xy_1)
            test_point_2 = at(inv_r, t_xy_2)

            if test_point_1.z < cone.H
                if test_point_2.z < cone.H
                    int_xy = (t_xy_1, t_xy_2)
                else 
                    int_xy = (-Inf, t_xy_1)
                end
            elseif test_point_2.z < cone.H
                int_xy = (t_xy_2, Inf)
            else
                return false
            end
        end     
    end

    if abs(inv_r.dir.z) < 1e-6
        if (inv_r.origin.z < 0.0 || inv_r.origin.z > cone.H)
            return false
        else
            int_z = (-Inf,Inf)
        end
    else
        int_z = (min(-inv_r.origin.z/inv_r.dir.z,(cone.H-inv_r.origin.z)/inv_r.dir.z), 
                 max(-inv_r.origin.z/inv_r.dir.z,(cone.H-inv_r.origin.z)/inv_r.dir.z))
    end

    t_1 = max(int_xy[1], int_z[1])
    t_2 = min(int_xy[2], int_z[2])

    if ((t_2-t_1) > 1e-6) && ( ((t_1 > inv_r.tmin) && (t_1 < inv_r.tmax)) || ((t_2 > inv_r.tmin) && (t_2 < inv_r.tmax)) )
        return true  
    else
        return false
    end
end

####################################################################################################
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
        T(hit.world_point),
        T(hit.normal),
        hit.surface_point,
        hit.t,
        T(hit.ray),
        hit.s
    )
end

"""
merge_overlapping_intervals(intervals)
    given a list of intervals of hitrecords (in ascending order of .t), this function merges it (useful for union of shapes)
"""
function _merge_intervals(intervals::Vector{Tuple{HitRecord, HitRecord}})
    if isempty(intervals)
        no_hits = Vector{Tuple{HitRecord, HitRecord}}()
        return no_hits 
    end

    merged = [intervals[1]] 

    for i in 2:length(intervals)
        current_interval = intervals[i]
        last_merged_interval = merged[end]
 
        if current_interval[1].t <= last_merged_interval[2].t
            if last_merged_interval[2].t < current_interval[2].t
            merged[end] = (last_merged_interval[1], current_interval[2])
            end
        else #no overlap
            push!(merged, current_interval) #this is not pushed in case of overlap
        end 
    end

    return merged
end

"""
_intersect_intervals(intervals_a, intervals_b)
    given two lists of intervals of hitrecords (in ascending order of .t), this function makes the intersection (useful for intersection of shapes)
"""
function _intersect_intervals(intervals_a::Vector{Tuple{HitRecord, HitRecord}}, intervals_b::Vector{Tuple{HitRecord, HitRecord}})
    intersected = Vector{Tuple{HitRecord, HitRecord}}()
    
    i = 1
    j = 1

    while i <= length(intervals_a) && j <= length(intervals_b)
        interval_a = intervals_a[i]
        interval_b = intervals_b[j]

        start_hit = (interval_a[1].t >= interval_b[1].t) ? interval_a[1] : interval_b[1]
        end_hit = (interval_b[2].t >= interval_a[2].t) ? interval_a[2] : interval_b[2]

        if start_hit.t < end_hit.t
            push!(intersected, (start_hit, end_hit))
        end

        if interval_a[2].t < interval_b[2].t
            i += 1
        else
            j += 1
        end
    end

    return intersected
end

function _subtract_intervals(intervals_a::Vector{Tuple{HitRecord, HitRecord}}, intervals_b::Vector{Tuple{HitRecord, HitRecord}})

    if isempty(intervals_a)
        return subtracted
    elseif isempty(intervals_b)
        return intervals_a
    end

    subtracted = Vector{Tuple{HitRecord, HitRecord}}()
    
    i = 1
    j = 1

    interval_a = intervals_a[i]

    while i <= length(intervals_a)

        # If only A remaining, push all the A
        if j > length(intervals_b) 
            push!(subtracted, interval_a)
            i += 1
            interval_a = (i <= length(intervals_a)) ? intervals_a[i] : nothing
            continue
        end

        interval_b = intervals_b[j]

        # Case 1: B before A
        if interval_b[2].t <= interval_a[1].t
            j += 1
            continue
        end

        # Case 2: B after A
        if interval_a[2].t <= interval_b[1].t
            push!(subtracted, interval_a)
            i += 1
            interval_a = (i <= length(intervals_a)) ? intervals_a[i] : nothing
            continue
        end

        # Case 3: Sovrapposition or A in B
        
        # Beginning of A
        if interval_a[1].t < interval_b[1].t
            push!(subtracted, (interval_a[1], interval_b[1]))
        end

        # End of A
        if interval_a[2].t > interval_b[2].t
            interval_a = (interval_b[2], interval_a[2])
            j += 1 
        else 
            i += 1
            interval_a = (i <= length(intervals_a)) ? intervals_a[i] : nothing
        end
    end

    return subtracted
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

    function union_shape(s1, s2, T::Transformation=Transformation(IDENTITY_MATR4x4))
        new(s1, s2, T)
    end

end

"""
function all_ray_intersection(u_shape::union_shape, r::Ray)
    Given a union of shapes and a ray, it returns all the HitRecords for the intersections between the ray and the shapes's union
"""
function all_ray_intersection(u_shape::union_shape, r::Ray)
    inv_r = inverse(u_shape.T)(r)
    hits_s1 = all_ray_intersection(u_shape.s1, inv_r)
    hits_s2 = all_ray_intersection(u_shape.s2, inv_r)

    if isempty(hits_s1) && isempty(hits_s2)
        no_hits = Vector{Tuple{HitRecord, HitRecord}}()
        return no_hits
    end

    all_intervals = vcat(hits_s1, hits_s2)
    sort!(all_intervals, by = i -> i[1].t)

    return _merge_intervals(all_intervals)
    
end

"""
function ray_intersection(u_shape::union_shape, r::Ray)
    Given a union of shapes and a ray, it returns the HitRecord for the first intersection between the ray and the shapes's union
"""
function ray_intersection(u_shape::union_shape, r::Ray)
    all_hits_intervals = all_ray_intersection(u_shape, r)

    if !isempty(all_hits_intervals)
        for (entry_hit, exit_hit) in all_hits_intervals
            if entry_hit.t > r.tmin
                return _transform_hit(entry_hit, u_shape.T)
            elseif exit_hit.t > r.tmin
                return _transform_hit(exit_hit, u_shape.T)
            end
        end
        return nothing
    else
        return nothing
    end
end

"""
function quick_ray_intersection(u_shape::union_shape, r::Ray)
    Given a union of shapes and a ray, it returns whether the intersection between the ray and the shape happens or not
"""
function quick_ray_intersection(u_shape::union_shape, r::Ray)
    all_hits_intervals = all_ray_intersection(u_shape, r)

    if !isempty(all_hits_intervals)
        for (entry_hit, exit_hit) in all_hits_intervals
            if entry_hit.t > r.tmin || exit_hit.t > r.tmin
                return true
            end
        end
        return false
    else
        return false
    end
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

    function intersec_shape(s1::Shape, s2::Shape, T::Transformation=Transformation(IDENTITY_MATR4x4))
        new(s1, s2, T)
    end

end

"""
function all_ray_intersection(i_shape::intersec_shape, r::Ray)
    Given an intersection of shapes and a ray, it returns all the HitRecords for the intersections between the ray and the shapes's intersection
"""
function all_ray_intersection(i_shape::intersec_shape, r::Ray)
    inv_r = inverse(i_shape.T)(r)
    hits_s1 = all_ray_intersection(i_shape.s1, inv_r)
    hits_s2 = all_ray_intersection(i_shape.s2, inv_r)

    if isempty(hits_s1) || isempty(hits_s2)
        no_hits = Vector{Tuple{HitRecord, HitRecord}}()
        return no_hits
    end

    return _intersect_intervals(hits_s1, hits_s2)
    
end

"""
function ray_intersection(i_shape::intersec_shape, r::Ray)
    Given an intersection of shapes and a ray, it returns the HitRecord for the first intersection between the ray and the shapes's intersection
"""
function ray_intersection(i_shape::intersec_shape, r::Ray)
    all_hits_intervals = all_ray_intersection(i_shape, r)

    if !isempty(all_hits_intervals)
        for (entry_hit, exit_hit) in all_hits_intervals
            if entry_hit.t > r.tmin
                return _transform_hit(entry_hit, i_shape.T)
            elseif exit_hit.t > r.tmin
                return _transform_hit(exit_hit, i_shape.T)
            end
        end
        return nothing
    else
        return nothing
    end
end

"""
function quick_ray_intersection(i_shape::intersec_shape, r::Ray)
    Given an intersection of shapes and a ray, it returns whether the intersection between the ray and the shape happens or not
"""
function quick_ray_intersection(i_shape::intersec_shape, r::Ray)
    all_hits_intervals = all_ray_intersection(i_shape, r)

    if !isempty(all_hits_intervals)
        for (entry_hit, exit_hit) in all_hits_intervals
            if entry_hit.t > r.tmin || exit_hit.t > r.tmin
                return true
            end
        end
        return false
    else
        return false
    end
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

    function diff_shape(s1::Shape, s2::Shape, T::Transformation=Transformation(IDENTITY_MATR4x4))
        new(s1, s2, T)
    end

end

"""
function all_ray_intersection(d_shape::diff_shape, r::Ray)
    Given a difference of shapes and a ray, it returns all the HitRecords for the intersections between the ray and the shapes's difference
"""
function all_ray_intersection(d_shape::diff_shape, r::Ray)
    inv_r = inverse(d_shape.T)(r)
    hits_s1 = all_ray_intersection(d_shape.s1, inv_r)
    hits_s2 = all_ray_intersection(d_shape.s2, inv_r)

    if isempty(hits_s1)
        no_hits = Vector{Tuple{HitRecord, HitRecord}}()
        return no_hits
    end

    return _subtract_intervals(hits_s1, hits_s2)
    
end

"""
function ray_intersection(d_shape::diff_shape, r::Ray)
    Given a difference of shapes and a ray, it returns the HitRecord for the first intersection between the ray and the shapes's difference
"""
function ray_intersection(d_shape::diff_shape, r::Ray)
    all_hits_intervals = all_ray_intersection(d_shape, r)

    if !isempty(all_hits_intervals)
        for (entry_hit, exit_hit) in all_hits_intervals
            if entry_hit.t > r.tmin
                return _transform_hit(entry_hit, d_shape.T)
            elseif exit_hit.t > r.tmin
                return _transform_hit(exit_hit, d_shape.T)
            end
        end
        return nothing
    else
        return nothing
    end
end

"""
function quick_ray_intersection(d_shape::diff_shape, r::Ray)
    Given a difference of shapes and a ray, it returns whether the intersection between the ray and the shape happens or not
"""
function quick_ray_intersection(d_shape::diff_shape, r::Ray)
    all_hits_intervals = all_ray_intersection(d_shape, r)

    if !isempty(all_hits_intervals)
        for (entry_hit, exit_hit) in all_hits_intervals
            if entry_hit.t > r.tmin || exit_hit.t > r.tmin
                return true
            end
        end
        return false
    else
        return false
    end
end
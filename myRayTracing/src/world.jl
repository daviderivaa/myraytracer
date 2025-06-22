#WORLD STRUCT AND METHODS

"""
struct World
    contains a list of shapes in the image
"""
struct World
    _shapes::Vector{Shape}
    _point_lights::Vector{PointLight}

    function World()
        new(Shape[], PointLight[])
    end
end

# SHAPES

"""
function add_shape!(w::World, s::Shape)
    inplace method to add a shape to the list
"""
function add_shape!(w::World, s::Shape)
    push!(w._shapes, s)
end

"""
function get_shapes(w::World)
    returns the whole _shapes vector
"""
function get_shapes(w::World)
    return w._shapes
end
"""
function get_single_shape(w::World, i::Int64)
    returns the i-th _shapes vector element
"""
function get_single_shape(w::World, i::Int64)
    return w._shapes[i]
end

#POINTLIGHT

"""
function add_light!(w::World, pl::PointLight)
    inplace method to add a point light to the list
"""
function add_light!(w::World, pl::PointLight)
    push!(w._point_lights, pl)
end

"""
function get_lights(w::World)
    returns the whole _point_lights vector
"""
function get_lights(w::World)
    return w._point_lights
end
"""
function get_single_light(w::World, i::Int64)
    returns the i-th _point_lights vector element
"""
function get_single_light(w::World, i::Int64)
    return w._point_lights[i]
end

#Compute ray ray_intersection
"""
function ray_intersection(w::World, r::Ray)
    Returns Nothing if the Ray doesn't intersect any shape or a HitRecord with the closest one
"""
function ray_intersection(w::World, r::Ray)

    closest::Union{HitRecord, Nothing} = nothing

    for shape in get_shapes(w)
        intersection = ray_intersection(shape, r)

        if intersection === nothing
            continue
        end

        if closest === nothing || intersection.t < closest.t -1e-6
            closest = intersection
        end
    end

    if closest !== nothing
        closest.normal = normalize(closest.normal)
    end

    return closest

end

"""
function is_point_visible(w::World, p::Point, observer_pos::Point)
    Returns True if a point is visible from a certain observer
"""
function is_point_visible(w::World, p::Point, observer_pos::Point)

        direction = p - observer_pos

        ray = Ray(observer_pos, direction)
        for shape in get_shapes(w)
            if quick_ray_intersection(shape, ray, 1.0+1e-6)
                return false
            end
        end
        return true
        
end
#WORLD STRUCT AND METHODS

"""
struct World
    contains a list of shapes in the image
"""
struct World
    _shapes::Vector{Shape}

    function World()
        new(Shape[])
    end
end

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
function get_single_shape(w::World, i::int64)
    returns the i-th _shapes vector element
"""
function get_single_shape(w::World, i::int64)
    return w._shapes[i]
end

#Compute ray ray_intersection
"""
function ray_intersection(w::World, r::Ray)
    searches for ray intersection with shapes and return an HitRecord variable that stores the nearest intersection to the origin
"""
function ray_intersection(w::World, r::Ray)
    error("missing function in ray_intersection()") #Temporary error, waiting for implementation
end

# DEFINING VEC POINT AND NORMAL STRUCTS AND CORRESPONDING OPERATIONS
############################################################################

"""
Defining Vec struct and methods:

    - x::Float64 ---> x component of the vector
    - y::Float64 ---> y component of the vector
    - z::Float64 ---> z component of the vector

""" 
struct Vec

    #Class for 3D vector
    x::Float64
    y::Float64
    z::Float64

    #Constructor with (0,0,0) as default values
    function Vec(x=0, y=0, z=0)
        new(x, y, z)
    end

end

###########################################################################

"""
Defining Vec2d struct and methods, it represents a point on a surface:

    - u::Float64 ---> first component of the vector
    - v::Float64 ---> second component of the vector

""" 
struct Vec2d

    #Class for 3D vector
    u::Float64
    v::Float64

    #Constructor with (0,0) as default values
    function Vec2d(u=0, v=0)
        new(u, v)
    end

end

###########################################################################

"""
Defining Point struct and methods:

    - x::Float64 ---> x position of the point
    - y::Float64 ---> y position of the point
    - z::Float64 ---> z position of the point

""" 
struct Point

    #Class for 3D point
    x::Float64
    y::Float64
    z::Float64

    #Constructor with (0,0,0) as default values
    function Point(x=0, y=0, z=0)
        new(x, y, z)
    end

end

############################################################################

"""
Defining Normal struct and methods:

    - x::Float64 ---> x component of the normal vector
    - y::Float64 ---> y component of the normal vector
    - z::Float64 ---> z component of the normal vector

""" 
struct Normal

    #Class for 3D normal
    x::Float64
    y::Float64
    z::Float64

    #Constructor with (0,0,0) as default values
    function Normal(x=0, y=0, z=0)
        new(x, y, z)
    end

end

############################################################################

"""
Exeption defined in order to check if the types of objects used are consistent
"""
struct Type_error <: Exception
    msg::String
end

"""
function is_close(a, b, epsilon=1e-6)
    checks if two object of the same type (Vec, Point or Normal) are similar
"""
function is_close(a::T, b::T, epsilon=1e-6) where T #Check if a and b are the same type, if not raise MethodError
    return abs(a.x - b.x) <= epsilon && abs(a.y - b.y) <= epsilon && abs(a.z - b.z) <= epsilon #Return True if the two variables are similiar, False otherwise
end

"""
function is_close(a, b, epsilon=1e-6)
    checks if two Vec2d are similar
"""
function is_close(a::Vec2d, b::Vec2d, epsilon=1e-6)
    return abs(a.u - b.u) <= epsilon && abs(a.v - b.v) <= epsilon #Return True if the two variables are similiar, False otherwise
end

"""
function print_element(a)
    prints the type of a and his components
"""
function print_element(a)
    try
        println("$(typeof(a))($(a.x), $(a.y), $(a.z))")
    catch
        throw(Type_error("Invalid variable type: $(typeof(a))")) #throw Type_error if a doesn't have 3 components
    end
end

"""
function Base.:+(a, b)
    addition between two Vec (returns Vec)
"""
function Base.:+(a::Vec, b::Vec)
    return Vec(a.x + b.x, a.y + b.y, a.z + b.z)
end

"""
function Base.:+(a, b)
    addition between two Vec2d (returns Vec2d)
"""
function Base.:+(a::Vec2d, b::Vec2d)
    return Vec2d(a.u + b.u, a.v + b.v)
end

"""
function Base.:+(a, b)
    addition between Point and Vec (returns Point)
"""
function Base.:+(a::Point, b::Vec)
    return Point(a.x + b.x, a.y + b.y, a.z + b.z)
end

"""
function Base.:+(a, b)
    addition between Vec and Point (returns Point)
"""
function Base.:+(a::Vec, b::Point)
    return Point(a.x + b.x, a.y + b.y, a.z + b.z)
end

"""
function Base.:-(a, b)
    difference between two Vec (returns Vec)
"""
function Base.:-(a::Vec, b::Vec)
    return Vec(a.x - b.x, a.y - b.y, a.z - b.z)
end

"""
function Base.:-(a, b)
    difference between two Vec2d (returns Vec2d)
"""
function Base.:-(a::Vec2d, b::Vec2d)
    return Vec2d(a.u - b.u, a.v - b.v)
end

"""
function Base.:-(a, b)
    difference between two Point (returns Vec)
"""
function Base.:-(a::Point, b::Point)
    return Vec(a.x - b.x, a.y - b.y, a.z - b.z)
end

"""
function Base.:-(a, b)
    difference between Point and Vec (returns Point)
"""
function Base.:-(a::Point, b::Vec)
    return Point(a.x - b.x, a.y - b.y, a.z - b.z)
end

"""
function Base.:*(lambda, a)
    product between a scalar and Vec
"""
function Base.:*(lambda::Float64, a::Vec)
    return Vec(lambda*a.x, lambda*a.y, lambda*a.z)
end

"""
function Base.:*(a, lambda)
    product between a Vec and scalar
"""
function Base.:*(a::Vec, lambda::Float64)
    return Vec(lambda*a.x, lambda*a.y, lambda*a.z)
end

"""
function neg(a)
    returns the opposite of a Normal
"""
function neg(a::Normal)
    return Normal(-1*a.x, -1*a.y, -1*a.z)
end

"""
function Base.:*(a, b)
    dot product between two Vec or Normal
"""
function Base.:*(a::Union{Vec,Normal}, b::Union{Vec,Normal})
    return a.x*b.x + a.y*b.y + a.z*b.z
end

"""
function squared_norm(a)
    returns the squared norm of a Vec or Normal    
"""
function squared_norm(a::Union{Vec,Normal})
        return a.x^2 + a.y^2 + a.z^2
end

"""
function norm(a)
    returns the norm of a Vec or Normal
"""
function norm(a::Union{Vec,Normal})
    return sqrt(squared_norm(a))
end


"""
function normalize(a::Vec)
    given a Vec, it returns the same vector after normalization
"""
function normalize(a::Vec)
    return Vec(a.x/norm(a), a.y/norm(a), a.z/norm(a))
end

"""
function normalize(a::Normal)
    given a Normal, it returns the same vector after normalization
"""
function normalize(a::Normal)
    return Normal(a.x/norm(a), a.y/norm(a), a.z/norm(a))
end

"""
function cross(a, b)
    cross product between two Vec or Normal variables
"""
function cross(a::Union{Vec,Normal}, b::Union{Vec,Normal})
    return Vec(a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x) #always returning a Vec 
end

"""
function Point_to_Vec(a)
    converts a Point into a Vec with same (x,y,z)
"""
function Point_to_Vec(a::Point)
    return Vec(a.x, a.y, a.z)    
end

"""
function Vec_to_Point(a)
    converts a Vec into a Point with same (x,y,z)
"""
function Vec_to_Point(a::Vec)
    return Point(a.x, a.y, a.z)    
end

"""
function Norm_to_Vec(a)
    converts a Normal into a Vec with same (x,y,z)
"""
function Norm_to_Vec(a::Normal)
    return Vec(a.x, a.y, a.z)    
end

"""
function Vec_to_Normal(a)
    converts a Vec into a Normal with same (x,y,z)
"""
function Vec_to_Normal(a::Vec)
    return Normal(a.x, a.y, a.z)    
end

"""
function create_onb_from_z(normal: Union[Vec, Normal])
    Creates a orthonormal basis (ONB) from a vector representing the z axis (normalized)

    Returns a tuple containing the three vectors (e1, e2, e3) of the basis. The result is such
    that e3 = normal.

    The `normal` vector must be *normalized*, otherwise this method won't work.
"""
function create_onb_from_z(normal::Union{Vec, Normal})

    x = normal.x
    y = normal.y
    z = normal.z

    sign = copysign(1.0, normal.z)
    a = -1.0 / (sign + normal.z)
    b = normal.x * normal.y * a

    e1 = Vec(1.0 + sign * normal.x * normal.x * a, sign * b, -sign * normal.x)
    e2 = Vec(b, sign + normal.y * normal.y * a, -normal.y)

    return (e1, e2, Vec(x, y, z))

end
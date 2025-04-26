import LinearAlgebra: cross, norm, normalize

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
function _are_xyz_close(a, b, epsilon=1e-6)
    checks if two object of the same type (Vec, Point or Normal) are similar
"""
function _are_xyz_close(a::T, b::T, epsilon=1e-6) where T #Check if a and b are the same type, if not raise MethodError
    return abs(a.x - b.x) <= epsilon && abs(a.y - b.y) <= epsilon && abs(a.z - b.z) <= epsilon #Return True if the two variables are similiar, False otherwise
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
    difference between two Point and Vec (returns Point)
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
    returns the squared norm of a Voc or Normal    
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
function normalize(a)
    given a Vec, it returns the same vector after normalization (returns Normal)
"""
function normalize(a::Vec)
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
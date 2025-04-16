import LinearAlgebra: cross, norm, normalize

# DEFINING VEC POINT AND NORMAL STRUCTS AND CORRESPONDING OPERATIONS
############################################################################

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

#Print a specific string by input when two invalid type variables are given
struct Type_error <: Exception
    msg::String
end

#SHARED FUNCTIONS 

function _are_xyz_close(a::T, b::T, epsilon=1e-6) where T #Check if a and b are the same type, if not raise MethodError
    return abs(a.x - b.x) <= epsilon && abs(a.y - b.y) <= epsilon && abs(a.z - b.z) <= epsilon #Return True if the two variables are similiar, False otherwise
end

#Print function
function print_element(a)
    try
        println("$(typeof(a))($(a.x), $(a.y), $(a.z))")
    catch
        throw(Type_error("Invalid variable type: $(typeof(a))")) #throw Type_error if a doesn't have 3 components
    end
end

#Addition functions
function Base.:+(a::Vec, b::Vec)
    return Vec(a.x + b.x, a.y + b.y, a.z + b.z)
end

function Base.:+(a::Point, b::Vec)
    return Point(a.x + b.x, a.y + b.y, a.z + b.z)
end

function Base.:+(a::Vec, b::Point)
    return Point(a.x + b.x, a.y + b.y, a.z + b.z)
end

#Difference functions
function Base.:-(a::Vec, b::Vec)
    return Vec(a.x - b.x, a.y - b.y, a.z - b.z)
end

function Base.:-(a::Point, b::Vec)
    return Point(a.x - b.x, a.y - b.y, a.z - b.z)
end

#Multiplication by a scalar 
function Base.:*(lambda::Float64, a::Vec)
    return Vec(lambda*a.x, lambda*a.y, lambda*a.z)
end

function Base.:*(a::Vec, lambda::Float64)
    return Vec(lambda*a.x, lambda*a.y, lambda*a.z)
end

#Negation function
function neg(a::Normal)
    return Normal(-1*a.x, -1*a.y, -1*a.z)
end

#Dot product
function Base.:*(a::Union{Vec,Normal}, b::Union{Vec,Normal})
    return a.x*b.x + a.y*b.y + a.z*b.z
end


#Squared norm
function squared_norm(a::Union{Vec,Normal})
        return a.x^2 + a.y^2 + a.z^2
end

#Norm
function norm(a::Union{Vec,Normal})
    return sqrt(squared_norm(a))
end

#Converting Vec into Normal
function normalize(a::Vec)
    return Normal(a.x/norm(a), a.y/norm(a), a.z/norm(a))
end

#Cross product
function cross(a::Union{Vec,Normal}, b::Union{Vec,Normal})
    return Vec(a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x) #always returning a Vec 
end

#Point to Vec
function Point_to_Vec(a::Point)
    return Vec(a.x, a.y, a.z)    
end
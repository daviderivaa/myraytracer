# DEFINING VEC POINT AND NORMAL STRUCTS AND CORRESPONDING OPERATIONS

############################################################################

#Stampa una stringa specificata nell'input quando gli passo un due variabili di tipo invalido
struct Type_error <: Exception
    msg::String
end

#SHARED FUNCTIONS 

function _are_xyz_close(a::T, b::T, epsilon=1e-6) where T #Check if a and b are the same type, if not raise MethodError
    return a.x - b.x <= epsilon && a.y - b.y <= epsilon && a.z - b.z <= epsilon #Return True if the two variables are similiar, False otherwise
end

#Print function
function print_element(a)
    try
        println("$(typeof(a))($(a.x), $(a.y), $(a.z))")
    catch
        throw(Type_error("Invalid variable type: $(typeof(a))")) #throw Type_error if a doesn't have 3 components
    end
end


function _add_operation_type(a, b, constructor)
    return constructor(a.x + b.x, a.y + b.y, a.z + b.z)
end

#Add two variables if they are of the same type and return the same type
function _add_xyz_same(a::T, b::T) where T
    
    if typeof(a)!=Point
        return _add_operation_type(a, b, typeof(a))
    else
        throw(Type_error("Trying summing two Point variables")) #if trying summing two Point variables raise a Type_error
    end
end

#Final adding function
function add_xyz(a, b)

    if typeof(a) == typeof(b) #executing a double check
        return _add_xyz_same(a, b)

    elseif (typeof(a) == Vec && typeof(b) == Point) || (typeof(a) == Point && typeof(b) == Vec)
        return _add_operation_type(a, b, Point)
    
    else
        throw(Type_error("Trying summing a $(typeof(a)) with a $(typeof(b)) "))

    end


end

#difference functions
function _sub_operation_type(a, b, constructor)
    return constructor(a.x - b.x, a.y - b.y, a.z - b.z)
end


function _sub_xyz_same(a::T,b::T) where T

    if typeof(a) == Point 
        return _sub_operation_type(a, b, Vec) #Difference between two Points is a Vec
    else
        return _sub_operation_type(a, b, typeof(a))
    end
end

#Final difference function
function sub_xyz(a,b)

    if typeof(a) == typeof(b)
        return _sub_xyz_same(a, b)

    elseif (typeof(a) == Vec && typeof(b) == Point) || (typeof(a) == Point && typeof(b) == Vec)
        return _sub_operation_type(a, b, Point)
    
    else
        throw(Type_error("Trying calculating the difference between a $(typeof(a)) and a $(typeof(b)) "))

    end
end


#Multiplication by a scalar 
function scalar_multip(lambda, a)

    constructor=typeof(a)
    
    if typeof(a)!=Point
        return constructor(lambda*a.x, lambda*a.y, lambda*a.z)
    else
        throw(Type_error("Multiplication by scalar ($lambda): variable is $(typeof(a)), expected Vec or Normal"))
    end
end

#Negation function
function neg(a)
    return scalar_multip(-1., a)
end


#Dot product definition
function _dot_prod(a, b)
    return a.x*b.x + a.y*b.y + a.z*b.z
end

#Final dot product
function dot(a, b)
    if typeof(a) == Point || typeof(b) == Point
        throw(Type_error("Trying to use dot product with a Point variable"))
    else
        return _dot_prod(a,b)
    end
end

#Squared norm
function squared_norm(a)
    if typeof(a) != Point
        return a.x^2 + a.y^2 + a.z^2
    else
        throw(Type_error("Trying to calculate norm of a Point variable"))
    end
end

#norm
function norm(a)
    return sqrt(squared_norm(a))
end

#normalize function
function normalize(a)
    return scalar_multip(1. /norm(a), a)
end


#Converting Vec into Normal and viceversa
function Vec_to_Normal_and_v(a)
    if typeof(a) == Vec
        return Normal(a.x, a.y, a.z)
    elseif typeof(a) == Normal
        return Vec(a.x, a.y, a.z)
    else
        throw(Type_error("Trying to convert a $(typeof(a)) into a Normal or Vec, expected Vec or Normal"))
    end
end


#Cross product
function cross(a, b)

    if typeof(a) != Point && typeof(b) != Point
        return Vec(a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x) #always returning a Vec ??

    else
        throw(Type_error("Trying to do cross product with Point, expected Vec or Normal"))
    end
end


#Point to Vec
function Point_to_Vec(a)

    if typeof(a) == Point
        return Vec(a.x, a.y, a.z)
    else
        throw(Type_error("Trying to convert $(typeof(a)) into a Vec, expected Point"))
    end
    
end

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
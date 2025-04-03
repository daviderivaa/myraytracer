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


function _add_operation_type(a, b, constructor)
    return constructor(a.x + b.x, a.y + b.y, a.z + b.z)
end

#Add two variables if they are of the same type and return the same type
function _add_xyz_same(a::T, b::T) where T

    type=typeof(a)
    
    if type!=Point
        return _add_operation_type(a, b, type)
    else
        throw(Type_error("Trying summing two Point variables")) #if trying summing two Point variables raise a Type_error
    end
end

#Final adding function
function add_xyz(a, b)

    if typeof(a)==typeof(b) #executing a double check
        return _add_xyz_same(a, b)

    elseif (typeof(a) == Vec && typeof(b) == Point) || (typeof(a) == Point && typeof(b) == Vec)
        return _add_operation_type(a, b, Point)
    
    else
        throw(Type_error("Trying summing a $(typeof(a)) with a $(typeof(b)) "))

    end


end


function _sub_operation_type(a, b, constructor)
    return constructor(a.x - b.x, a.y - b.y, a.z - b.z)
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
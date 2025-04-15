
#DEFINING TRANSFORMATION STRUCT AND OPERATIONS
using LinearAlgebra

#########################################################################################

const IDENTITY_MATR4x4 = Matrix{Float64}(I(4))

struct Transformation
    m::Matrix{Float64}
    invm::Matrix{Float64}

    function Transformation(M::Matrix{Float64})
        invM = inv(M)
        new(M, invM)
    end
end

########################################################################################

struct Transformation_error <: Exception
    msg::String
end

#Tranformation functions

function _are_matr_close(m1::Matrix{Float64}, m2::Matrix{Float64}, epsilon=1e-6)
    return all(abs.(m1 .- m2) .< epsilon)
end

#Check if a Transformation matrix is consistent with its inverse
function is_consistent(T::Transformation)
    prod = T.m*T.invm
    return _are_matr_close(prod, IDENTITY_MATR4x4)
end

#Initialize a Translation for a given vector
function traslation(v)
    try

        m = [1.0 0.0 0.0 v.x;
         0.0 1.0 0.0 v.y;
         0.0 0.0 1.0 v.z;
         0.0 0.0 0.0 1.0]

        T = Transformation(m)

        return T

    catch
        throw(Transformation_error("Cannot define a traslation"))
    end
end

#Scaling by a single factor or three factors, one for each axis
function scaling(a, b=nothing, c=nothing)
    try

        b === nothing && (b = a)
        c === nothing && (c = a)

        m = [a 0.0 0.0 0.0;
            0.0 b 0.0 0.0;
            0.0 0.0 c 0.0;
            0.0 0.0 0.0 1.0]

        T = Transformation(m)

        return T
        
    catch
        throw(Transformation_error("Cannot define a scaling transformation"))
    end
end

#Initialize a Rotation around a given axis
function rotation(axis, angle)
    if axis == "x"
        m = [1.0 0.0 0.0 0.0;
             0.0 cos(angle) -sin(angle) 0.0;
             0.0 sin(angle) cos(angle) 0.0;
             0.0 0.0 0.0 1.0]
        T = Transformation(m)
        return T
    elseif axis == "y"
        m = [cos(angle) 0.0 sin(angle) 0.0;
             0.0 1.0 0.0 0.0;
             -sin(angle) 0.0 cos(angle) 0.0;
             0.0 0.0 0.0 1.0]
        T = Transformation(m)
        return T
    elseif axis == "z"
        m = [cos(angle) -sin(angle) 0.0 0.0;
             sin(angle) cos(angle) 0.0 0.0;
             0.0 0.0 1.0 0.0;
             0.0 0.0 0.0 1.0]
        T = Transformation(m)
        return T
    else 
        throw(Transformation_error("Axis $axis not defined for rotations"))
    end  
end


#Tranformation for Point
function apply_transf(T::Transformation, a::Point)
    if ((a.x*T.m[4,1] + a.y*T.m[4,2] + a.z*T.m[4,3] + T.m[4,4]) == 1.0)
        return Point((a.x*T.m[1,1] + a.y*T.m[1,2] + a.z*T.m[1,3] + T.m[1,4]), 
                        (a.x*T.m[2,1] + a.y*T.m[2,2] + a.z*T.m[2,3] + T.m[2,4]), 
                        (a.x*T.m[3,1] + a.y*T.m[3,2] + a.z*T.m[3,3] + T.m[3,4]))
    else 
        throw(Transformation_error("Point type not preserved in transformation"))
    end
end


#Tranformation for Vec
function apply_transf(T::Transformation, a::Vec)
    if ((a.x*T.m[4,1] + a.y*T.m[4,2] + a.z*T.m[4,3]) == 0.0)
        return Vec((a.x*T.m[1,1] + a.y*T.m[1,2] + a.z*T.m[1,3]), 
                    (a.x*T.m[2,1] + a.y*T.m[2,2] + a.z*T.m[2,3]), 
                    (a.x*T.m[3,1] + a.y*T.m[3,2] + a.z*T.m[3,3]))
    else
        throw(Transformation_error("Vector type not preserved in transformation"))
    end
end


#Tranformation for Normal
function apply_transf(T::Transformation, a::Normal)
    if ((a.x*T.m[1,4] + a.y*T.m[2,4] + a.z*T.m[3,4]) == 0.0)
        return Normal((a.x*T.m[1,1] + a.y*T.m[2,1] + a.z*T.m[3,1]), 
                        (a.x*T.m[1,2] + a.y*T.m[2,2] + a.z*T.m[3,2]), 
                        (a.x*T.m[1,3] + a.y*T.m[2,3] + a.z*T.m[3,3]))
    else
        throw(Transformation_error("Normal type not preserved in transformation"))
    end
end
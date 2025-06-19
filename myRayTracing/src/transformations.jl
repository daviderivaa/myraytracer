
#DEFINING TRANSFORMATION STRUCT AND OPERATIONS

#########################################################################################

const IDENTITY_MATR4x4 = [1.0 0.0 0.0 0.0;
                          0.0 1.0 0.0 0.0;
                          0.0 0.0 1.0 0.0;
                          0.0 0.0 0.0 1.0]


"""
Defining Tranformation struct and methods:

    - m::Matrix{Float64} ---> matrix associated to the transformation
    - invm::Matrix{Float64} ---> inverse of m (useful in order to apply the transformation to Normal)

""" 
struct Transformation
    m::Matrix{Float64}
    invm::Matrix{Float64}

    function Transformation(M::Matrix{Float64}=IDENTITY_MATR4x4)
        invM = inv(M)
        new(M, invM)
    end
end

########################################################################################

"""
Exeption defined in order to check if the transformations are created correctly and work properly on different types of objects
"""
struct Transformation_error <: Exception
    msg::String
end

"""
function _are_matr_close(m1, m2, epsilon=1e-6)
    checks if two matrix are similar
"""
function _are_matr_close(m1::Matrix{Float64}, m2::Matrix{Float64}, epsilon=1e-6)
    return all(abs.(m1 .- m2) .< epsilon)
end

"""
function is_consistent(T)
    checks if T.invm is truly the inverse of T.m 
"""
function is_consistent(T::Transformation)
    prod = T.m*T.invm
    return _are_matr_close(prod, IDENTITY_MATR4x4)
end

"""
function inverse(T)
    returns the inverse of the transformation T (T.m and T.invm swapped)
"""
function inverse(T::Transformation)
    A = Transformation(T.invm)
    return A
end

"""
function translation(v)
    creates the transformation in case of translation by a given vector v
"""
function translation(v)
    #try

        m = [1.0 0.0 0.0 v.x;
             0.0 1.0 0.0 v.y;
             0.0 0.0 1.0 v.z;
             0.0 0.0 0.0 1.0]

        T = Transformation(m)

        return T

    #catch
    #    throw(Transformation_error("Cannot define a translation"))
    #end
end

"""
function scaling(a, b=nothing, c=nothing)
    creates the transformation in case of scaling by three given factors (a,b,c), one for each axis
    if only "a" is given, it is used on all axes
"""
function scaling(a, b=nothing, c=nothing)
    #try

        b === nothing && (b = a)
        c === nothing && (c = a)

        m = [a 0.0 0.0 0.0;
             0.0 b 0.0 0.0;
             0.0 0.0 c 0.0;
             0.0 0.0 0.0 1.0]

        T = Transformation(m)

        return T
        
    #catch
    #    throw(Transformation_error("Cannot define a scaling transformation"))
    #end
end

"""
function rotation(axis, angle)
    creates the transformation in case of a rotation around a given axis by a given angle (radiant)
"""
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

"""
function (T::Tranformation)(a::Point)
    allows to apply the transformation on a point by using " T(a) "
"""
function (T::Transformation)(a::Point)
    #if abs(a.x*T.m[4,1] + a.y*T.m[4,2] + a.z*T.m[4,3] + T.m[4,4] - 1.0) < 1e-6
        return Point((a.x*T.m[1,1] + a.y*T.m[1,2] + a.z*T.m[1,3] + T.m[1,4]), 
                     (a.x*T.m[2,1] + a.y*T.m[2,2] + a.z*T.m[2,3] + T.m[2,4]), 
                     (a.x*T.m[3,1] + a.y*T.m[3,2] + a.z*T.m[3,3] + T.m[3,4]))
    #else 
    #    throw(Transformation_error("Point type not preserved in transformation"))
    #end
end

"""
function (T::Transformation)(a::Vec)
    allows to apply the transformation on a vector by using " T(a) "
"""
function (T::Transformation)(a::Vec)
    #if abs(a.x*T.m[4,1] + a.y*T.m[4,2] + a.z*T.m[4,3]) < 1e-6
        return Vec((a.x*T.m[1,1] + a.y*T.m[1,2] + a.z*T.m[1,3]), 
                   (a.x*T.m[2,1] + a.y*T.m[2,2] + a.z*T.m[2,3]), 
                   (a.x*T.m[3,1] + a.y*T.m[3,2] + a.z*T.m[3,3]))
    #else
    #    throw(Transformation_error("Vector type not preserved in transformation"))
    #end
end

"""
function (T::Transformation)(a::Normal)
    allows to apply the transformation on a normal by using " T(a) "
""" 
function (T::Transformation)(a::Normal)
    return Normal((a.x*T.invm[1,1] + a.y*T.invm[2,1] + a.z*T.invm[3,1]), 
                    (a.x*T.invm[1,2] + a.y*T.invm[2,2] + a.z*T.invm[3,2]), 
                    (a.x*T.invm[1,3] + a.y*T.invm[2,3] + a.z*T.invm[3,3]))
end

"""
function (A::Transformation)(B::Transformation)
    allows to compose two transformations by using " A(B) " 
"""
function (A::Transformation)(B::Transformation)
    return Transformation(A.m*B.m)
end
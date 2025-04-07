
#DEFINING TRANSFORMATION STRUCT AND OPERATIONS
using LinearAlgebra


#########################################################################################

const IDENTITY_MATR4x4 = Matrix{Float64}(I(4))

struct Transformation
    m::Matrix{Float64}
    invm::Matrix{Float64}

    function Transformation(m::Matrix{Float64}=IDENTITY_MATR4x4, invm::Matrix{Float64}=IDENTITY_MATR4x4)
        new(m, invm)
    end

    function Transformation(m::Matrix{Float64})
        invm = inv(m)
        new(m, invm)
    end
end

########################################################################################

#Tranformation functions

function _are_matr_close(m1::Matrix{Float64}, m2::Matrix{Float64}, epsilon=1e-6)
    return all(abs.(m1 .- m2) .< epsilon)
end

#Check if a Transformation matrix is consistent with its inverse
function is_consistent(T::Transformation)
    prod = T.m*T.invm
    return _are_matr_close(prod, IDENTITY_MATR4x4)
end
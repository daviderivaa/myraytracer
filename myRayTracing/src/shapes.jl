#SHAPE STRUCTS
using LinearAlgebra

#DEFINING AN ABSTRACT TYPE FOR SHAPES
"""Abstarct struct for shapes"""
abstract type Shape
end

"""Abstarct method for ray_intersection"""
function ray_intersection(shape::Shape, r::Ray)
    throw(Type_error("ray_intersection method not implemented for $(typeof(shape))"))
end

"""Abstarct method for quick_ray_intersection"""
function quick_ray_intersection(shape::Shape, r::Ray)
    throw(Type_error("quick_ray_intersection method not implemented for $(typeof(shape))"))
end

#DEFINING SUBSTRUCTS
#SPHERE STRUCT
"""
struct Sphere <: Shape
    Creates a 3D unit sphere centered in the origin of the axes. A transfromation can be passed to translate and transform it into an ellipsoid
"""
struct Sphere <: Shape

    transformation::Transformation

    function Sphere(transformation::Transformation=Tranformation(Matrix{Float64}(I(4))))
        new(transformation)
    end

end
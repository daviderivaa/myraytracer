#POINT LIGHT STRCUT DEFINITION FOR POINT-LIGHT TRACING ALGORITHM


"""
This struct contains informations about the light sources for Point-Light Tracing algorithm.

    - pos::Point --> represents the 3D position of the light.
    - color::RGB --> color of the light.
    - linear_radius::Float64 --> radius used to compute the solid angle of the light (default is 0.0).
     (Dirac Delta assumption doesn't allow a solid angle definition, however radiance should go as (r/d)^2 where d is distance).

"""
struct PointLight

    pos::Point
    color::RGB
    linear_radius::Float64

    function PointLight(p::Point, c::RGB, lr::Float64=0.0)
        new(p, c, lr)
    end
end
#PIGMENTS, BRDF AND MATERIAL STRUCTS
#DEFINING ABSTRACT TYPE AND METHODS FOR PIGMENTS

"""Abstarct struct for pigments. It associates a pigment, a color, to pixels"""
abstract type Pigment
end

"""Abstarct method for get_color"""
function get_color(pigment::Pigment, uv::Vec2d)
    throw(Type_error("get_color method not implemented for $(typeof(pigment))"))
end

#DEFINING SUBSTRUCTS

#UNIFORM PIGMENT STRUCT
"""
struct UniformPigment <: Pigment
    it gives a uniform pigment all over the surface

    color::RGB --> the single color of the surface
end
"""
struct UniformPigment <: Pigment

    color::RGB

    function UniformPigment(color::RGB=RGB(0.0, 0.0, 0.0))
        new(color)
    end

end

"""
function get_color(pigment::UniformPigment, uv::Vec2d)
    it returns the uniform color on the surface
end
"""
function get_color(pigment::UniformPigment, uv::Vec2d)

    return pigment.color

end

#CHECKERED PIGMENT STRUCT
"""
struct CheckeredPigment <: Pigment
    it gives a checkered pigment over the surface

    color1::RGB --> first color in the checkered
    color2::RGB --> second color in the checkered
    steps::Int64 --> number of steps in the checkboard
end
"""
struct CheckeredPigment <: Pigment

    color1::RGB
    color2::RGB
    steps::Int64

    function CheckeredPigment(color1::RGB=RGB(0.0, 0.0, 0.0), color2::RGB=RGB(1.0, 1.0, 1.0), steps::Int64=10)
        new(color1, color2, steps)
    end

end

"""
function get_color(pigment::CheckeredPigment, uv::Vec2d)
    it returns the color on the surface in that precise point of the checkereboard
end
"""
function get_color(pigment::CheckeredPigment, uv::Vec2d)

    int_u = floor(Int, uv.u * pigment.steps)
    int_v = floor(Int, uv.v * pigment.steps)

    return (int_u % 2 == int_v % 2) ? pigment.color1 : pigment.color2
    
end

#IMAGE PIGMENT STRUCT
"""
struct ImagePigment <: Pigment
    it wraps a given PFM image all over the surface

    image::HdrImage --> image to wrap over the surface
end
"""
struct ImagePigment <: Pigment

    image::HdrImage

    function ImagePigment(image::HdrImage)
        new(image)
    end

end

"""
function get_color(pigment::ImagePigment, uv::Vec2d)
    it returns the color on the surface in that precise point of the image
end
"""
function get_color(pigment::ImagePigment, uv::Vec2d)
    
    img = pigment.image
    col = clamp(floor(Int, uv.u * img.width) + 1, 1, img.width)
    row = clamp(floor(Int, uv.v * img.height) + 1, 1, img.height)
    return img.pixels[row, col]
    
end


#############################################################################################################
#DEFINING ABSTRACT TYPE AND METHODS FOR BRDF

"""Abstarct struct for BRDF (Bidirectional Reflectance Distribution Function)"""
abstract type BRDF
end

"""Abstarct method for eval"""
function Eval(brdf::BRDF, uv::Vec2d, normal::Union{Normal, Nothing}=nothing, in_dir::Union{Vec, Nothing}=nothing, out_dir::Union{Vec, Nothing}=nothing)
    throw(Type_error("get_color method not implemented for $(typeof(brdf))"))
end

"""
Abstract method for ray scattering for path tracing methods
"""
function scatter_ray(brdf::BRDF, pcg::PCG, in_dir::Vec, interaction_point::Point, normal::Normal, depth::Int64)
    throw(Type_error("scatter_ray method invalid for these arguments"))
end

#DEFINING SUBSTRUCTS
#DIFFUSIVE BRDF

"""
struct DiffuseBRDF <: BRDF
    A class representing an ideal diffuse BRDF (also called «Lambertian»)

    pigment::Pigment --> pigment of the BRDF
    reflectance::Float64 --> reflectance of the BRDF

end
"""
struct DiffuseBRDF <: BRDF

    pigment::Pigment
    reflectance::Float64

    function DiffuseBRDF(pigment::Pigment=UniformPigment(RGB(1.0, 1.0, 1.0)), reflectance=1.0)
        new(pigment, reflectance)
    end

end

"""
function eval(brdf::DiffuseBRDF, uv::Vec2d)
    evaluates the brdf in a specific point given pigment at a given reflectance
end
"""
function Eval(brdf::DiffuseBRDF, uv::Vec2d, normal::Union{Normal, Nothing}=nothing, in_dir::Union{Vec, Nothing}=nothing, out_dir::Union{Vec, Nothing}=nothing)

    return get_color(brdf.pigment, uv) * (brdf.reflectance / π)

end

"""
scatter ray implementation for Diffusive BRDF type
"""
function scatter_ray(brdf::DiffuseBRDF, pcg::PCG, in_dir::Vec, interaction_point::Point, normal::Normal, depth::Int64)
    
    e1, e2, e3 = create_onb_from_z(normal)
    cos_theta_sq = norm_random!(pcg)
    cos_theta = √(cos_theta_sq)
    sin_theta = √(1.0 - cos_theta_sq)
    phi = 2.0 * π * norm_random!(pcg)

    return Ray(interaction_point, e1 * cos(phi) * cos_theta + e2 * sin(phi) * cos_theta + e3 * sin_theta, 1.0e-3, Inf, depth)

end


# SPECULAR BRDF TYPE AND METHODS
"""
struct SpecularBRDF <: BRDF
    A class representing an ideal mirror

    pigment::Pigment --> pigment of the BRDF
    reflectance::Float64 --> treeshold angle in radiant

end
"""
struct SpecularBRDF <: BRDF

    pigment::Pigment
    reflectance::Float64

    function SpecularBRDF(pigment::Pigment, reflectance::Float64 = π/180.0)
        new(pigment, reflectance)
    end

end

"""
function eval(brdf::SpecularBRDF, uv::Vec2d, normal::Normal, in_dir::Vec, out_dir::Vec)
    evaluates the brdf in a specific point given pigment and reflectance
end
"""
function Eval(brdf::SpecularBRDF, uv::Vec2d, normal::Normal, in_dir::Vec, out_dir::Vec)

    n_normal = normalize(normal)
    n_in_dir = normalize(in_dir)
    n_out_dir = normalize(out_dir)

    theta_in = acos(n_normal * n_in_dir)
    theta_out = acos(n_normal * n_out_dir)

    if abs(theta_out - theta_in) < brdf.reflectance -1e-6
        return get_color(brdf.pigment, uv)
    else
        return RGB(0.0, 0.0, 0.0)
    end

end

"""
scatter ray implementation for Specular BRDF type (not using PCG because it's deterministic)
"""
function scatter_ray(brdf::SpecularBRDF, pcg::PCG, in_dir::Vec, interaction_point::Point, normal::Normal, depth::Int64)

    ray_dir = normalize(Vec(in_dir.x, in_dir.y, in_dir.z))
    n_normal = normalize(Norm_to_Vec(normal))
    dot_prod = n_normal *ray_dir

    return Ray(interaction_point, ray_dir - Norm_to_Vec(normal) * 2.0 * dot_prod, 1e-5, Inf, depth)

end


##############################################################################################################
#DEFINING MATERIAL STRUCT

"""Struct for a material, it contains a brdf and a radiance (a pigment)"""
struct Material

    brdf::BRDF
    emitted_radiance::Pigment

    function Material(brdf::BRDF=DiffuseBRDF(), emitted_radiance::Pigment=UniformPigment(RGB(0.0, 0.0, 0.0)))
        new(brdf, emitted_radiance)
    end

end
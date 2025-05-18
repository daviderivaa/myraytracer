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

    color::RGB{Float64} --> the single color of the surface
end
"""
struct UniformPigment <: Pigment

    color::RGB{Float64}

    function UniformPigment(color::RGB{Float64}=RGB(0.0, 0.0, 0.0))
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

    color1::RGB{Float64} --> first color in the checkered
    color2::RGB{Float64} --> second color in the checkered
    steps::Int64 --> number of steps in the checkboard
end
"""
struct CheckeredPigment <: Pigment

    color1::RGB{Float64}
    color2::RGB{Float64}
    steps::Int64

    function CheckeredPigment(color1::RGB{Float64}=RGB(0.0, 0.0, 0.0), color2::RGB{Float64}=RGB(1.0, 1.0, 1.0), steps::Int64=10)
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

#DEFINING ABSTRACT TYPE AND METHODS FOR BRDF

"""Abstarct struct for BRDF (Bidirectional Reflectance Distribution Function)"""
abstract type BRDF
end

"""Abstarct method for eval"""
function eval(brdf::BRDF, uv::Vec2d, normal::Normal=nothing, in_dir::Vec=nothing, out_dir::Vec=nothing)
    throw(Type_error("get_color method not implemented for $(typeof(brdf))"))
end

#DEFINING SUBSTRUCTS

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
function eval(brdf::DiffuseBRDF, normal::Normal, in_dir::Vec, out_dir::Vec, uv::Vec2d)
    evaluates the brdf in a specific point given pigment and reflectance
end
"""
function eval(brdf::DiffuseBRDF, uv::Vec2d)

    return get_color(brdf.pigment, uv) * (brdf.reflectance / π)

end

#DEFINING MATERIAL STRUCT

"""Struct for a material, it contains a brdf and a radiance (a pigment)"""
struct Material

    brdf::BRDF
    emitted_radiance::Pigment

    function Material(brdf::BRDF=DiffuseBRDF(), emitted_radiance::Pigment=UniformPigment(RGB(0.0, 0.0, 0.0)))
        new(brdf, emitted_radiance)
    end

end
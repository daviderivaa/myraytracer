# RENDERS STRUCT AND METHODS

"""
abstract type for rendering
"""
abstract type Renderer
end

"""Abstarct method for radiance on a ray --> rendering image"""
function (RND::Renderer)(ray::Ray)
    throw(Type_error("rendering method not implemented for $(typeof(RND)) or $(typeof(ray)) "))
end

"""
Simplest renderer (2 colors)

- w::World --> World variable that contains the scene
- back_col::RGB(Float64) --> background color (default is black)
- h_color::RGB{Float64} --> hit shape color (default is white)
"""
struct OnOffRenderer <: Renderer

    w::World
    b_color::RGB{Float64}
    h_color::RGB{Float64}

    function OnOffRenderer(wor::World, back_col::RGB{Float64}=RGB(0.0, 0.0, 0.0), hit_color::RGB{Float64}=RGB(1.0, 1.0, 1.0))
        new(wor, back_col, hit_color)
    end

end

"""
Concrete rendering function for simplest renderer
"""
function (RND::OnOffRenderer)(ray::Ray)
    if ray_intersection(RND.w, ray) !== nothing
        return RND.h_color
    else
        return RND.b_color
    end
end

"""
FlatRenderer estimates the solution of the rendering equation by using only the pigment of the hit surface and computing the finale radiance.
- w::World --> World variable that contains the scene
- back_col::RGB(Float64) --> background color (default is black)
"""
struct FlatRenderer <: Renderer

    w::World
    b_color::RGB{Float64}

    function FlatRenderer(wor::World, back_col = RGB(0.0, 0.0, 0.0))
        new(wor, back_col)
    end
end

"""
Concrete rendering function with BRDF
"""
function (RND::FlatRenderer)(ray::Ray)

    hit = ray_intersection(RND.w, ray)

    if hit === nothing
        return RND.b_color
    else 
        return (eval(hit.s.material.brdf, hit.surface_point) + get_color(hit.s.material.emitted_radiance, hit.surface_point))
    end
end
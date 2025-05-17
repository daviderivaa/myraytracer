# RENDERS STRUCT AND METHODS

"""
abstract type for rendering
"""
abstract type Render
end

"""Abstarct method for radiance on a ray --> rendering image"""
function (RND::Render)(ray::Ray)
    throw(Type_error("rendering method not implemented for $(typeof(RND)) or $(typeof(ray)) "))
end

"""
Simplest renderer (2 colors)

- w::World --> World variable that contains the scene
- back_col::RGB(Float64) --> background color
- h_color::RGB{Float64} --> hit shape color
"""
struct OnOffRender <: Render

    w::World
    b_color::RGB{Float64}
    h_color::RGB{Float64}

    function OnOffRender(wor::World, back_col::RGB{Float64}=RGB(0.0, 0.0, 0.0), hit_color::RGB{Float64}=RGB(1.0, 1.0, 1.0)) #Default colors are Black (background) and White
        new(wor, back_col, hit_color)
    end

end

"""
Concrete rendering function for simplest renderer
"""
function (RND::OnOffRender)(ray::Ray)
    if ray_intersection(RND.w, ray) !== nothing
        return RND.h_color
    else
        return RND.b_color
    end
end
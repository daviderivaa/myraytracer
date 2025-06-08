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
- back_col::RGB --> background color (default is black)
- h_color::RGB --> hit shape color (default is white)
"""
struct OnOffRenderer <: Renderer

    w::World
    b_color::RGB
    h_color::RGB

    function OnOffRenderer(wor::World, back_col::RGB=RGB(0.0, 0.0, 0.0), hit_color::RGB=RGB(1.0, 1.0, 1.0))
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
- back_col::RGB --> background color (default is black)
"""
struct FlatRenderer <: Renderer

    w::World
    b_color::RGB

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
        return (Eval(hit.s.material.brdf, hit.surface_point) + get_color(hit.s.material.emitted_radiance, hit.surface_point))
    end
end


"""
PathTracer renderer is the main algorithm that allows to throw rays and calcute radiance at each step.
It's a recursive algorithm which stops thank to the Russian Roulette.

- w::World --> contains the scene
- b_color::RGB --> background color of the scene
- pcg::PCG --> random number generator
- num_rays::Int64 --> number of rays thrown at each iteration
- max_depth::Int64 --> maximun number number of iteration for each ray
- rr_limit::Int64 --> Russian Roulette limit
"""
struct PathTracer <: Renderer

    w::World
    b_color::RGB
    pcg::PCG
    num_rays::Int64
    max_depth::Int64
    rr_limit::Int64

    function PathTracer(w::World, b_color::RGB = RGB(0.0, 0.0, 0.0), pcg::PCG = new_PCG(), num_rays::Int64 = 10, max_depth::Int64 = 10, rr_limit::Int64 = 3)
        new(w, b_color, pcg, num_rays, max_depth, rr_limit)
    end

end

function (RND::PathTracer)(ray::Ray)

    if ray.depth > RND.max_depth
        return RGB(0.0, 0.0, 0.0)
    end

    hit_record = ray_intersection(RND.w, ray)

    if hit_record === nothing
        return RND.b_color
    end

    hit_material = hit_record.s.material
    hit_color = get_color(hit_material.brdf.pigment, hit_record.surface_point)
    emitted_radiance = get_color(hit_material.emitted_radiance, hit_record.surface_point)

    hit_color_lum = max(hit_color.r, hit_color.g, hit_color.b)

    #Russian Roulette
    if ray.depth >= RND.rr_limit
        q = max(0.05, 1.0 - hit_color_lum)

        if norm_random!(RND.pcg) > q
            hit_color *= 1.0 / (1.0 - q)
        else
            return emitted_radiance
        end
    end

    cum_radiance = RGB(0.0, 0.0, 0.0)

    if hit_color_lum > 0.0
        for ray_index in 1:RND.num_rays
            new_ray = scatter_ray(hit_material.brdf, RND.pcg, hit_record.ray.dir, hit_record.world_point, hit_record.normal, ray.depth + 1)
            new_radiance = RND(new_ray)
            cum_radiance += (hit_color * new_radiance)
        end
    end

    return (emitted_radiance + cum_radiance * (1.0 / (RND.num_rays)))

end


############################################################################################

# POINT LIGHT TRACING

"""
Renderer for PointLight Tracing algorithm.
    - w::World --> world variable which contains shapes and light sources.
    - b_color::RGB --> background color (default is black).
    - ambient_color::RGB --> ambient color (default is not black but close in order to avoid low luminosity).
"""
struct PointLightRenderer <: Renderer

    w::World
    b_color::RGB
    ambient_color::RGB

    function PointLightRenderer(w::World, b_color::RGB=RGB(0.0, 0.0, 0.0), ambient_color::RGB=RGB(0.1, 0.1, 0.1))
        if isempty(w._point_lights)
            throw(Type_error("For PointLight Tracer use at least 1 light source"))
        end
        new(w, b_color, ambient_color)
    end

end

"""
PointLight Tracing algorithm
"""
function (RND::PointLightRenderer)(ray::Ray)

    hit_record = ray_intersection(RND.w, ray)

    if hit_record === nothing
        return RND.b_color
    end

    hit_material = hit_record.s.material
    emitted_color = get_color(hit_material.emitted_radiance, hit_record.surface_point)

    result_color = RND.ambient_color + emitted_color

    for light in get_lights(RND.w)

        if is_point_visible(RND.w, light.pos, hit_record.world_point)

            distance_vec = hit_record.world_point - light.pos
            distance = norm(distance_vec)
            in_dir = normalize(distance_vec)
            n_hit_normal = normalize(hit_record.normal)
            cos_theta = max(0.0, -(in_dir * n_hit_normal))

            if light.linear_radius > 0.0
                distance_factor = (light.linear_radius / distance)^2
            else
                distance_factor = 1.0
            end

            brdf_color = Eval(hit_material.brdf, hit_record.surface_point, hit_record.normal, in_dir, neg(ray.dir))
            result_color += brdf_color * light.color * cos_theta * distance_factor
        end
    end

    return result_color

end
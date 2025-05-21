module myRayTracing

#including libraries and export methods

include("Color_and_HdrImage.jl")
export RGB, HdrImage, print_image, _read_float, _parse_endianness, _read_line

include("PFMfunctions.jl")
export read_pfm, InvalidPfmFileFormat, write_pfm

include("LdrImage.jl")
export tone_mapping!, gamma_correction!, read_user_input

include("geometry.jl")
export Vec, Vec2d, Point, Normal, Type_error, print_element, is_close, neg, squared_norm, norm, normalize, cross, Point_to_Vec, Vec_to_Point, Norm_to_Vec, Vec_to_Normal

include("transformations.jl")
export Transformation, is_consistent, inverse, traslation, scaling, rotation

include("ray.jl")
export Ray, at, is_close

include("camera.jl")
export Camera, fire_single_ray, OrthogonalCamera, PerspectiveCamera, aperture_deg

include("ImageTracer.jl")
export ImageTracer, fire_ray, fire_all_rays!

include("materials.jl")
export Pigment, UniformPigment, CheckeredPigment, ImagePigment, get_color, BRDF, DiffuseBRDF, Eval, Material

include("shapes.jl")
export Shape, Sphere, Plane, Rectangle, ray_intersection, quick_ray_intersection, HitRecord, is_close, union_shape, intersec_shape, diff_shape

include("world.jl")
export World, add_shape!, get_shapes, get_single_shape, ray_intersection, is_point_visible

include("pcg.jl")
export new_PCG, random!, norm_random!

include("render.jl")
export Renderer, OnOffRenderer, FlatRenderer

end #module myRayTracing
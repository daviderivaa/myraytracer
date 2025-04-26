module myRayTracing

#including libraries and export methods

include("Color_and_HdrImage.jl")
export RGB, HdrImage, print_image, _read_float, _parse_endianness, _read_line

include("PFMfunctions.jl")
export read_pfm, InvalidPfmFileFormat

include("LdrImage.jl")
export tone_mapping!, gamma_correction!, read_user_input

include("geometry.jl")
export Vec, Point, Normal, Type_error, print_element, _are_xyz_close, neg, squared_norm, norm, normalize, cross, Point_to_Vec, Vec_to_Point, Norm_to_Vec

include("transformations.jl")
export Transformation, is_consistent, traslation, scaling, rotation

include("ray.jl")
export Ray, at, is_close

include("camera.jl")
export Camera, fire_ray, OrthogonalCamera, PerspectiveCamera, aperture_deg

include("ImageTracer.jl")
export ImageTracer, fire_ray, fire_all_rays

end #module myRayTracing
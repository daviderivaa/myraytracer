module myRayTracing

#including libraries and export methods

include("Color_and_HdrImage.jl")
export RGB, HdrImage, print_image, _read_float, _parse_endianness, _read_line, InvalidPfmFileFormat

include("PFMfunctions.jl")
export read_pfm

include("LdrImage.jl")
export tone_mapping!, gamma_correction!, read_user_input

include("geometry.jl")
export Vec, Point, Normal, print_element, _are_xyz_close, neg, dot, squared_norm, norm, normalize, cross, Point_to_Vec

include("transformations.jl")
export Transformation, is_consistent, traslation, scaling, rotation, apply_transf

include("ray.jl")
export Ray, at, is_close, transform_ray

include("camera.jl")
export Camera, fire_ray, OrthogonalCamera, PerspectiveCamera, aperture_deg

end #module myRayTracing
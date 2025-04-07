module myRayTracing

include("Color_and_HdrImage.jl")
include("PFMfunctions.jl")
include("LdrImage.jl")
include("geometry.jl")
include("transformations.jl")

#Esporta le classi e le funzioni per poterle leggere nel main
export RGB, HdrImage, print_image, _read_float, _parse_endianness, _read_line, InvalidPfmFileFormat
export read_pfm
export tone_mapping!, gamma_correction!, read_user_input
export Vec, Point, Normal, print_element, add_xyz, sub_xyz, scalar_multip, neg, dot, squared_norm, norm, normalize, Vec_to_Normal_and_v, cross, Point_to_Vec
export Transformation, is_consistent

end
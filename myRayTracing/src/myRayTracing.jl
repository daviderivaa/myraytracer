module myRayTracing

include("Color_and_HdrImage.jl")
include("PFMfunctions.jl")
include("LdrImage.jl")

#Esporta le classi e le funzioni per poterle leggere nel main
export RGB, HdrImage, set_pixel, get_pixel, print_image, valid_pixel
export InvalidPfmFileFormat, _read_float, _read_line, _parse_endianness,_parse_img_size, _read_pfm
export luminosity, average_luminosity, normalize_image, _clamp, clamp_image, tone_mapping, write_ldr_image, user_alpha_and_gamma, user_png_output, read_user_imput

end
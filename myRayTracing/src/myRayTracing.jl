module myRayTracing

include("Color_and_HdrImage.jl")
include("PFMfunctions.jl")
include("LdrImage.jl")

#Esporta le classi e le funzioni per poterle leggere nel main
export RGB, HdrImage, print_image
export read_pfm
export tone_mapping, write_ldr_image, read_user_imput

end
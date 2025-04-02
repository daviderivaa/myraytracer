using Pkg
Pkg.activate("myRayTracing")
using Images
using myRayTracing #Fino a qua non toccare che serve a importare classi e librerie correttamente

format, width, height, endianness, pixel_data = read_pfm("./memorial.pfm")
alpha, gamma, output_file_name, output_file_format = read_user_input()

image = HdrImage(pixel_data, width, height)

tone_mapping!(image, alpha)
gamma_correction!(image, gamma)

complete_output_file_name = "$(output_file_name)_g$(gamma)a$(alpha).$(output_file_format)"
save("./memorial_images/" * complete_output_file_name, image.pixels)
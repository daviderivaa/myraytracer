using Pkg
Pkg.activate("myRayTracing")
using Images
using myRayTracing #Fino a qua non toccare che serve a importare classi e librerie correttamente

format, width, height, endianness, pixel_data = read_pfm("./memorial.pfm")
alpha, gamma, output_file_name = read_user_input()

image = HdrImage(pixel_data, width, height)

tone_mapping!(image, alpha)
gamma_correction!(image, gamma)

save("./memorial_images/" * output_file_name, image.pixels)
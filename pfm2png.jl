using Pkg
Pkg.activate("myRayTracing")
using Images
using myRayTracing

format, width, height, endianness, pixel_data = read_pfm("./demo/demo.pfm")
alpha, gamma, output_file_name, output_file_format = read_user_input()

image = HdrImage(pixel_data, width, height)

tone_mapping!(image, alpha)
gamma_correction!(image, gamma)

complete_output_file_name = "$(output_file_name)_g$(gamma)a$(alpha).$(output_file_format)"
save("./demo/demo_images/" * complete_output_file_name, image.pixels)
using Pkg
Pkg.activate("myRayTracing")
using Images
using myRayTracing

function convert_pfm_to_png(path::String, pfm_file::String, output_file_name::String, alpha::Float64 = 0.3, gamma::Float64 = 1.0, output_file_format::String="png")
    format, width, height, endianness, pixel_data = read_pfm(pfm_file)
    image = HdrImage(pixel_data, width, height)
    tone_mapping!(image, alpha, 0.5)
    gamma_correction!(image, gamma)

    complete_output_file_name = path * "$(output_file_name)_g$(gamma)a$(alpha).$(output_file_format)"
    save(complete_output_file_name, image.pixels)
end

# # Not used now
# if abspath(PROGRAM_FILE) == @__FILE__
#     pfm_file = ARGS[1]
#     alpha, gamma, output_file_name, output_file_format = read_user_input()
#     path = "./"
#     convert_pfm_to_png(path, pfm_file, alpha, gamma, output_file_name, output_file_format)
# end
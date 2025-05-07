using Pkg
Pkg.activate("myRayTracing")
using Images
using myRayTracing

function convert_pfm_to_png(pfm_file::String, alpha::Float64 = 0.3, gamma::Float64 = 1.0, output_file_name::String, output_file_format::String="png")
    format, width, height, endianness, pixel_data = read_pfm(pfm_file)
    image = HdrImage(pixel_data, width, height)
    tone_mapping!(image, alpha)
    gamma_correction!(image, gamma)

    complete_output_file_name = "$(output_file_name)_g$(gamma)a$(alpha).$(output_file_format)"
    save("./demo/" * complete_output_file_name, image.pixels)
end

# Esegui solo se chiamato da terminale
if abspath(PROGRAM_FILE) == @__FILE__
    pfm_file = ARGS[1]
    alpha, gamma, output_file_name, output_file_format = read_user_input()
    convert_pfm_to_png(pfm_file, alpha, gamma, output_file_name, output_file_format)
end
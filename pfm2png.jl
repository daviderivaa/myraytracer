#FUNCTION TO CONVERT A PFM INTO A PNG FILE WITH TONE MAPPING

function convert_pfm_to_png(path::String, pfm_file::String, output_file_name::String, alpha::Float64 = 0.3, lum = nothing, gamma::Float64 = 1.0, output_file_format::String="png")
    format, width, height, endianness, pixel_data = read_pfm(pfm_file)
    image = HdrImage(pixel_data, width, height)
    tone_mapping!(image, alpha, lum)
    gamma_correction!(image, gamma)

    complete_output_file_name = path * "$(output_file_name)_g$(gamma)a$(alpha).$(output_file_format)"
    save(complete_output_file_name, image.pixels)
end

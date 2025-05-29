###TONE MAPPING & LDR IMAGE!

"""
Exeption defined in order to check if the values of objects used are consistent
"""
struct Value_Error <: Exception
    msg::String
end

"""
function _luminosity(color::RGB)
    compute luminosity as (max{R, G, B}+min{R, G, B}) / 2
"""
function _luminosity(color::RGB)
    return (max(color.r, color.g, color.b) + min(color.r, color.g, color.b))/2
end

"""
function _average_luminosity(img::HdrImage, delta)
    compute average luminosity using logaritmic formula: 
    cumsum = 0.0
    for pix in img.pixels
        cumsum += log10(delta + _luminosity(pix))
    end
    return 10^(cumsum / length(img.pixels))
"""
function _average_luminosity(img::HdrImage, delta=1e-4)
    cumsum = 0.0
    if delta <= 0
        throw(Value_Error("Invalid value for delta: $(delta)"))
    end
    for pix in img.pixels
        cumsum += log10(delta + _luminosity(pix))
    end
    return 10^(cumsum / length(img.pixels))
end

"""
function _normalize_image!(img::HdrImage, alpha, lum=nothing)
    inplace method that normalizes RGB pixels of an Hdr image by scaling product with alpha/luminosity
    using lum as a nullable type

"""
function _normalize_image!(img::HdrImage, alpha=0.18, lum=nothing)
    lum = isnothing(lum) ? _average_luminosity(img) : lum
    #lum = max(_average_luminosity(img), 1e-2)
    scale = alpha / lum
    #scale = min(alpha / lum, 10.0)

    img.pixels = [RGB(p.r * scale, p.g * scale, p.b * scale) for p in img.pixels]
end

"""
function _clamp(x)
    return x/(1+x)
"""
function _clamp(x)
    if x > 1.0
        return 1.0
    else
        return x
    end
end

"""
function _clamp_image!(img::HdrImage)
    inplace method that uses _clamp function on RGB pixels
"""
function _clamp_image!(img::HdrImage)
    img.pixels = [RGB(_clamp(p.r), _clamp(p.g), _clamp(p.b)) for p in img.pixels]
end

"""
function tone_mapping!(img::HdrImage, alpha, lum=nothing)
    inplace method that executes tone mapping on an HdrImage:
    
    _normalize_image(img, alpha, lum)
    _clamp_image(img)
"""
function tone_mapping!(img::HdrImage, alpha, lum=nothing)
    _normalize_image!(img, alpha, lum)
    _clamp_image!(img)
end

"""
function gamma_correction!(img::HdrImage, gamma=1.0)
    inplace method that gives gamma correction to the RGB pixels:

    img.pixels = [RGB(p.r^(1.0/gamma),
                      p.g^(1.0/gamma),
                      p.b^(1.0/gamma)) for p in img.pixels]
"""
function gamma_correction!(img::HdrImage, gamma=1.0)
    img.pixels = [RGB(p.r^(1.0/gamma),
                p.g^(1.0/gamma),
                p.b^(1.0/gamma)) for p in img.pixels]
end

"""
function _user_alpha_and_gamma()
    takes alpha and gamma value from the user
"""
function _user_alpha_and_gamma()
    while true
        print("Insert alpha value: ")
        a_str = readline()
        print("Insert gamma value: ")
        g_str = readline()
        a = 0
        g = 0

        try
            a = parse(Float64, a_str)
            g = parse(Float64, g_str)
            if a>0 && g>0
                return a, g
            else
                throw(Type_error("Error: alpha and gamma must be grater than zero"))
            end
        catch
            throw(Type_error("Error: try other alpha and gamma"))
        end

    end

end

"""
function _user_output_filename()
    takes output file name from user
"""
function _user_output_filename()
    while true
        print("Write output file name: ")
        file_name = readline()

        if !isempty(strip(file_name))
            return file_name
        else
            throw(Type_error("Error: please insert file name!"))
        end

    end

end

"""
function _user_output_format()
    takes output file format: png or jpg
"""
function _user_output_format()
    while true
        print("Choose either png or jpg file format: ")
        file_format = readline()

        if file_format == "png" || file_format == "jpg"
            return file_format
        else
            println("Error: digit 'png' o 'jpg'. Try again.")
        end

    end

end

"""
function read_user_input()
    sets output file info and alpha, gamma parameters from user:

    alpha, gamma = _user_alpha_and_gamma()
    file_name = _user_output_filename()
    file_format = _user_output_format()
    
    return alpha, gamma, file_name, file_format
"""
function read_user_input()
    alpha, gamma = _user_alpha_and_gamma()
    file_name = _user_output_filename()
    file_format = _user_output_format()
    return alpha, gamma, file_name, file_format
end
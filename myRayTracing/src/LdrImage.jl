###TONE MAPPING & LDR IMAGE!

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
function _average_luminosity(img::HdrImage, delta=1e-10)
    cumsum = 0.0
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
function _normalize_image!(img::HdrImage, alpha, lum=nothing)
    lum = isnothing(lum) ? _average_luminosity(img) : lum
    scale = alpha / lum

    img.pixels = [RGB(p.r * scale, p.g * scale, p.b * scale) for p in img.pixels]
end

"""
function _clamp(x)
    return x/(1+x)
"""
function _clamp(x)
    return x / (1+x)
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

#applica la gamma correction
function gamma_correction!(img::HdrImage, gamma=1.0)
    img.pixels = [RGB(p.r^(1.0/gamma),
                p.g^(1.0/gamma),
                p.b^(1.0/gamma)) for p in img.pixels]
end

#prende in ingresso da terminale alpha e gamma
function _user_alpha_and_gamma()
    while true
        print("Inserire il valore di alpha: ")
        a_str = readline()
        print("Inserire il valore di gamma: ")
        g_str = readline()
        a = 0
        g = 0

        try
            a = parse(Float64, a_str)
            g = parse(Float64, g_str)
            if a>0 && g>0
                return a, g
            else
                println("Errore, fornire valori positivi di alpha e gamma")
            end
        catch
            println("Errore, fornire valori accettabili di alpha e gamma")
        end

    end

end

#prende in ingresso da terminale il nome del file di output
function _user_output_filename()
    while true
        print("Come si desidera chiamare il file di output? ")
        file_name = readline()

        if !isempty(strip(file_name))
            return file_name
        else
            println("Errore: inserire il nome del file.")
        end

    end

end

#prende in ingresso da terminale il nome del formato del file in output (png o jpg)
function _user_output_format()
    while true
        print("Si desidera produrre un file png o jpg? ")
        file_format = readline()

        if file_format == "png" || file_format == "jpg"
            return file_format
        else
            println("Errore: digitare 'png' o 'jpg'. Riprova.")
        end

    end

end

#composizione delle due funzioni sopra
function read_user_input()
    alpha, gamma = _user_alpha_and_gamma()
    file_name = _user_output_filename()
    file_format = _user_output_format()
    return alpha, gamma, file_name, file_format
end
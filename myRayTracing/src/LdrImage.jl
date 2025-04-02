###TONE MAPPING & LDR IMAGE!

#uno dei possibili modi di valutare la luminosità di un pixel
function _luminosity(color::RGB)
    return (max(color.r, color.g, color.b) + min(color.r, color.g, color.b))/2
end

#calcola la luminosità logaritmica media dell'immagine
function _average_luminosity(img::HdrImage, delta=1e-10)
    cumsum = 0.0
    for pix in img.pixels
        cumsum += log10(delta + _luminosity(pix))
    end
    return 10^(cumsum / length(img.pixels))
end

#normalizza la luminosità dell'immagine
function _normalize_image!(img::HdrImage, alpha, lum=nothing)
    lum = isnothing(lum) ? _average_luminosity(img) : lum
    scale = alpha / lum

    img.pixels = [RGB(p.r * scale, p.g * scale, p.b * scale) for p in img.pixels]
end

function _clamp(x)
    return x / (1+x)
end

#correzione per punti troppo luminosi
function _clamp_image!(img::HdrImage)
    img.pixels = [RGB(_clamp(p.r), _clamp(p.g), _clamp(p.b)) for p in img.pixels]
end

#effettua tutte le operazioni per il tone mapping
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
function user_alpha_and_gamma()
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
                println("Errore, fornire valori positivi dei alpha e gamma")
            end
        catch
            println("Errore, fornire valori accettabili di alpha e gamma")
        end

    end

end

#prende in ingresso da terminale il nome di un file .png o .jpg
function user_png_output()
    while true
        print("Inserire il nome del file .png o .jpg in output: ")
        file_name = readline()

        if endswith(file_name, ".png") || endswith(file_name, ".jpg")
            return file_name
        else
            println("Errore: il nome del file deve terminare con '.png' o '.jpg'. Riprova.")
        end

    end

end

#composizione delle due funzioni sopra
function read_user_input()
    alpha, gamma = user_alpha_and_gamma()
    file_name = user_png_output()
    return alpha, gamma, file_name
end
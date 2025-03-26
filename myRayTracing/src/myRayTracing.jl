module myRayTracing
import Colors
import ColorTypes: ColorTypes, RGB

#Esporta le classi e le funzioni per poterle leggere nel main
export RGB, HdrImage, set_pixel, get_pixel, print_image, valid_pixel
export luminosity, average_luminosity, normalize_image, _clamp, clamp_image, tone_mapping, write_ldr_image, user_alpha_and_gamma, user_png_output, read_user_imput
export InvalidPfmFileFormat, _read_float, _read_line, _parse_endianness,_parse_img_size, _read_pfm


########################################################################################################

#NOT USING PERSONAL COLOR STRUCT: left as comment
###COLOR STRUCT

# struct Color
#     r::Float64
#     g::Float64
#     b::Float64

#     # Costruttore con valori di default nulli
#     function Color(r=0.0, g=0.0, b=0.0)
#         new(r, g, b)
#     end
        
# end

# ###COLOR FUNCTIONS!!!

# #Somma due colori
# function add(c1::Color, c2::Color)
#     return Color(c1.r + c2.r, c1.g + c2.g, c1.b + c2.b)
# end

# #Moltiplilca colore per scalare
# function multiply(c1::Color, a::Float64)
#     return Color(c1.r * a, c1.g * a, c1.b * a)
# end

# #Controlla se due numeri sono vicini entro 1e-5
# function is_close(x, y, epsilon = 1e-5)
#     return abs(x - y) < epsilon
# end

# #Controlla se due colori sono vicini per ogni componente
# function is_colors_close(c1::Color, c2:: Color)
#     return is_close(c1.r, c2.r) && is_close(c1.g, c2.g) && is_close(c1.b, c2.b)
# end


# #Setta il colore di un pixel
# function set_pixel(img::HdrImage, line::Int, column::Int, c::Color)
#     img.pixels[line, column] = c
# end

# #Legge il colore di un pixel
# function get_pixel(img::HdrImage, column::Int, line::Int)
#     println(img.pixels[column, line])
# end

#######################################################################################################

###IMAGE STRUCT!

mutable struct HdrImage
    width::Int
    height::Int
    pixels::Matrix{RGB}

    function HdrImage(width, height)  # Costruttore senza dati
        pixels = Matrix{RGB}(undef, height, width)
        new(width, height, pixels)
    end

    function HdrImage(pixel_data, width, height)  # Costruttore con dati
        if length(pixel_data) != width * height * 3
            throw(ArgumentError("Il numero di elementi in pixel_data non corrisponde a width * height * 3"))
        end

        pixels = Matrix{RGB}(undef, height, width)
        for i in 1:height
            for j in 1:width
                index = ((i-1) * width + (j-1)) * 3 + 1
                pixels[height-i+1, j] = RGB(pixel_data[index], pixel_data[index+1], pixel_data[index+2]) #Inverto la lettura dei pixel sulle righe per tenere conto che il file PFM è bottom-top
            end
        end
        new(width, height, pixels)
    end
end

###IMAGE FUNCTIONS!!!

#Stampa un'immagine 
function print_image(img::HdrImage)
    println("Colore dei pixel dell'immagine $(img.height)x$(img.width):")
    println(img)
end

#Controlla che un pixel stia nell'immagine
function valid_pixel(img::HdrImage, column, line)
    return line >= 1 && line <= img.height && column >= 1 && column <= img.width
end

#######################################################################################

###TONE MAPPING!

#uno dei possibili modi di valutare la luminosità di un pixel
function luminosity(color::RGB)
    return (max(color.r, color.g, color.b) + min(color.r, color.g, color.b))/2
end

#calcola la luminosità logaritmica media dell'immagine
function average_luminosity(img::HdrImage, delta=1e-10)
    cumsum = 0.0
    for pix in img.pixels
        cumsum += log10(delta + luminosity(pix))
    end
    return 10^(cumsum / length(img.pixels))
end

#normalizza la luminosità dell'immagine
function normalize_image(img::HdrImage, alpha, lum=nothing)
    lum = isnothing(lum) ? average_luminosity(img) : lum
    scale = alpha / lum

    return [RGB(p.r * scale, p.g * scale, p.b * scale) for p in img.pixels]
end

function _clamp(x)
    return x / (1+x)
end

#correzione per punti troppo luminosi
function clamp_image(img::HdrImage)
    return [RGB(_clamp(p.r), _clamp(p.g), _clamp(p.b)) for p in img.pixels]
end

#effettua tutte le operazioni per il tone mapping
function tone_mapping(img::HdrImage, alpha, lum=nothing)
    img.pixels = normalize_image(img, alpha, lum)
    img.pixels = clamp_image(img)
end

#applica la gamma correction
function write_ldr_image(img::HdrImage, gamma=1.0)
    return [RGB(p.r^(1/gamma),
                p.g^(1/gamma),
                p.b^(1/gamma)) for p in img.pixels]
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
            return a, g
        catch
            println("Errore, fornire valori corretti di alpha e gamma")
        end

    end

end

#prende in ingresso da terminale il nome di un file .png
function user_png_output()
    while true
        print("Inserire il nome del file .png in output: ")
        file_name = readline()

        if endswith(file_name, ".png")
            return file_name
        else
            println("Errore: il nome del file deve terminare con '.png'. Riprova.")
        end

    end

end

#composizione delle due funzioni sopra
function read_user_imput()
    alpha, gamma = user_alpha_and_gamma()
    file_name = user_png_output()
    return alpha, gamma, file_name
end

########################################################################################################


###PFM FUNCTIONS

#Stampa una stringa specificata nell'input quando gli passo un formato PFM invalido
struct InvalidPfmFileFormat <: Exception
    msg::String
end

#Legge numeri 64bit Floating point
function _read_float(io::IO, endianness)
    try
        raw = read(io, UInt32)  #Legge 4 byte come UInt32
        if endianness > 0
            raw = bswap(raw)  #Se big-endian, inverte i byte
        end
        return reinterpret(Float32, raw)  #Converte il valore a Float32
    catch
        throw(InvalidPfmFileFormat("Invalid float number"))
    end
end


#Legge una riga di un file PFM
function _read_line(io::IO)
    result = UInt8[]  #Array dinamico di byte
    while !eof(io)  #Continua fino alla fine del file
        cur_byte = read(io, UInt8)  #Legge un singolo byte
        if cur_byte == 0x0A  #Controlla se è il carattere '\n'
            if length(result) == 0 #Se la linea è nulla, cioè contiene solo l'"a capo" avvisa
                throw(InvalidPfmFileFormat("Empty line"))
            end
            return String(result)  #Converte i byte in stringa e restituisce
        end
        push!(result, cur_byte)  #Aggiunge il byte alla lista
    end
    return String(result)  #Se EOF, restituisce comunque il risultato
end

#Legge le dimensioni dell'immagine
function _parse_img_size(line)
    elements = split(line, " ")  #Divide la stringa in parti
    if length(elements) != 2
        throw(InvalidPfmFileFormat("Invalid image size specification"))
    end

    try
        width, height = parse(Int, elements[1]), parse(Int, elements[2])
        if width < 0 || height < 0
            throw(InvalidPfmFileFormat("Invalid width/height (negative value)"))
        end
        return width, height
    catch
        throw(InvalidPfmFileFormat("Invalid width/height"))
    end
end

#Legge l'endianness del binario
function _parse_endianness(endian)

    value = try
        parse(Float64, endian) #Prova a leggere l'endianness come float
    catch
        throw(InvalidPfmFileFormat("Unable to read endianness")) #Stampa l'errore in lettura pfm
    end

    if value==0.0 || value===NaN
        throw(InvalidPfmFileFormat("Endiannes = 0 or NaN")) #Stampa errore se endianness è uguale a 0 o NaN
    end

    return value
end

function _read_pfm(filename)
    open(filename, "r") do io
        format = _read_line(io)  #"Pf" o "PF"
        width, height = _parse_img_size(_read_line(io))  #Larghezza e altezza
        endianness = _parse_endianness(_read_line(io))  #Legge il valore di scala
        
        # Legge i dati pixel
        pixel_data = [ _read_float(io, endianness) for _ in 1:(3 * width * height) ]
       
        return format, width, height, endianness, pixel_data
    end
end

#######################################################################################################

end
module myRayTracing

export HdrImage, set_pixel, get_pixel, print_image, valid_pixel, _read_float, _read_line, _parse_endianness,_parse_img_size #Esporta le classi e le funzioni per poterle leggere nel main


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

#######################################################################################################

###IMAGE STRUCT!

struct HdrImage
    width::Int
    height::Int
    pixels::Matrix{Color}

    function HdrImage(width::Int=0, height::Int=0) #Costruttore personalizzato con valori di default nulli
        pixels = [Color() for _ in 1:width, _ in 1:height]
        new(width, height, pixels)
    end
end

###IMAGE FUNCTIONS!!!

#Setta il colore di un pixel
function set_pixel(img::HdrImage, line::Int, column::Int, c::Color)
    img.pixels[line, column] = c
end

#Legge il colore di un pixel
function get_pixel(img::HdrImage, column::Int, line::Int)
    println(img.pixels[column, line])
end

#Stampa un'immagine pixel per pixel
function print_image(img::HdrImage)
    println("Colore dei pixel dell'immagine $(img.height)x$(img.width):")
    for i in 1:img.width
        for j in 1:img.height
            println("Pixel ($i, $j): ", img.pixels[i, j])
        end
    end
end

#Controlla che un pixel stia nell'immagine
function valid_pixel(img::HdrImage, column::Int, line::Int)
    return line >= 1 && line <= img.height && column >= 1 && column <= img.width
end

########################################################################################################


###PFM FUNCTIONS

#Legge numeri 32bit Floating point
function _read_float(io::IO, endianness::Int)
    raw = read(io, UInt32)  #Legge 4 byte come UInt32 (default legge in little-endian)
    if endianness > 0
        raw = bswap(raw)  #Se big-endian, inverte i byte
    end
    return reinterpret(Float32, raw)  #Converte il valore a Float32
end

#Legge una riga di un file PFM
function _read_line(io::IO)
    result = UInt8[]  #Array dinamico di byte
    while !eof(io)  #Continua fino alla fine del file
        cur_byte = read(io, UInt8)  #Legge un singolo byte
        if cur_byte == 0x0A  #Controlla se è il carattere '\n'
            return String(result)  #Converte i byte in stringa e restituisce
        end
        push!(result, cur_byte)  #Aggiunge il byte alla lista
    end
    return String(result)  #Se EOF, restituisce comunque il risultato
end

#Legge le dimensioni dell'immagine
#Stampa una stringa specificata nell'input quando gli passo un formato PFM invalido
struct InvalidPfmFileFormat <: Exception
    msg::String
end

function _parse_img_size(line::String)
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
function _parse_endianness()
end

function read_pfm(filename)
    open(filename, "r") do io
        format = _read_line(io)  # "Pf" o "PF"
        width, height = parse.(Int, split(_read_line(io)))  # Larghezza e altezza
        scale = parse(Float32, _read_line(io))  # Legge il valore di scala
        
        endianness = scale < 0 ? 1 : 0  # Se negativo → Big-endian, altrimenti Little-endian

        # Legge i dati pixel
        pixel_data = [ _read_float(io, endianness) for _ in 1:(width * height) ]

        return pixel_data, width, height, format
    end
end

#######################################################################################################

end
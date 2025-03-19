module myRayTracing

export Color, add, multiply, is_close, is_colors_close, HdrImage, set_pixel, get_pixel, print_image, valid_pixel #Esporta le classi e le funzioni per poterle leggere nel main

###COLOR STRUCT!!!

struct Color
    r::Float64
    g::Float64
    b::Float64

    # Costruttore con valori di default nulli
    function Color(r=0.0, g=0.0, b=0.0)
        new(r, g, b)
    end
        
end

###COLOR FUNCTIONS!!!

#Somma due colori
function add(c1::Color, c2::Color)
    return Color(c1.r + c2.r, c1.g + c2.g, c1.b + c2.b)
end

#Moltiplilca colore per scalare
function multiply(c1::Color, a::Float64)
    return Color(c1.r * a, c1.g * a, c1.b * a)
end

#Controlla se due numeri sono vicini entro 1e-5
function is_close(x, y, epsilon = 1e-5)
    return abs(x - y) < epsilon
end

#Controlla se due colori sono vicini per ogni componente
function is_colors_close(c1::Color, c2:: Color)
    return is_close(c1.r, c2.r) && is_close(c1.g, c2.g) && is_close(c1.b, c2.b)
end

###COLOR TESTS!!!

###IMAGE STRUCT!!!

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

###IMAGE TESTS!!!

#Controlla che un pixel stia nell'immagine
function valid_pixel(img::HdrImage, column::Int, line::Int)
    return line >= 1 && line <= img.height && column >= 1 && column <= img.width
end

###PFM FUNCTIONS & TESTS!!!

function _read_float()
end




###
function _read_line()
end





###
function _parse_img_size()
end





###
function _parse_endianness()
end






end
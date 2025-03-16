module myRayTracing

export Color, add, multiply, is_close, is_colors_close, HdrImage, set_pixel, get_pixel, print_image, valid_pixel #Esporta le classi e le funzioni per poterle leggere nel main

struct Color
    r::Float64
    g::Float64
    b::Float64

    # Costruttore con valori di default nulli
    function Color(r=0.0, g=0.0, b=0.0)
        new(r, g, b)
    end
        
end

function add(c1::Color, c2::Color)
    return Color(c1.r + c2.r, c1.g + c2.g, c1.b + c2.b) #Somma due colori
end

function multiply(c1::Color, a::Float64)
    return Color(c1.r * a, c1.g * a, c1.b * a) #Colore moltiplicato
end

function is_close(x, y, epsilon = 1e-5)
    return abs(x - y) < epsilon #Controlla se due numeri sono vicini entro 1e-5
end

function is_colors_close(c1::Color, c2:: Color)
    return is_close(c1.r, c2.r) && is_close(c1.g, c2.g) && is_close(c1.b, c2.b) #Controlla se due colori sono vicini per ogni componente
end

struct HdrImage
    height::Int
    width::Int
    pixels::Matrix{Color}

    function HdrImage(height::Int=0, width::Int=0) # Costruttore personalizzato con valori di default nulli
        pixels = [Color() for _ in 1:height, _ in 1:width]
        new(height, width, pixels)
    end
end

function set_pixel(img::HdrImage, line::Int, column::Int, c::Color)
    img.pixels[line, column] = c #Setta il colore di un pixel
end

function get_pixel(img::HdrImage, line::Int, column::Int)
    println(img.pixels[line, column]) #Legge il colore di un pixel
end

function print_image(img::HdrImage)
    println("Colore dei pixel dell'immagine $(img.height)x$(img.width):") #Stampa un'immagine pixel per pixel
    for i in 1:img.height
        for j in 1:img.width
            println("Pixel ($i, $j): ", img.pixels[i, j])
        end
    end
end

function valid_pixel(img::HdrImage, line::Int, column::Int)
    return line >= 1 && line <= img.height && column >= 1 && column <= img.width
end

end
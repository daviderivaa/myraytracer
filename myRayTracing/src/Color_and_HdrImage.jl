import Colors
import ColorTypes: ColorTypes, RGB


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
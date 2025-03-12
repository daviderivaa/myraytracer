struct Color
    r::Float64
    g::Float64
    b::Float64

    # Costruttore con valori di default
    Color(r=0.0, g=0.0, b=0.0) = new(r, g, b)
end

struct HdrImage
    width::Int
    height::Int
    pixels::Vector{Color}

    # Costruttore personalizzato con valori di default
    function HdrImage(width::Int=0, height::Int=0)
        pixels = [Color() for _ in 1:(width * height)]
        new(width, height, pixels)
    end
end
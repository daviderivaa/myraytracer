struct Color
    r::Float64
    g::Float64
    b::Float64

    # Costruttore con valori di default
    Color(r=0.0, g=0.0, b=0.0) = new(r, g, b)
end

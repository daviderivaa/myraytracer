import Colors
import ColorTypes: ColorTypes, RGB
import ColorVectorSpace
import Base: *


###IMAGE STRUCT!

"""
mutable struct HdrImage:

    width, height (Int, Int) --> image dimensions
    pixels --> 2D image matrix, represented as 1D array. Each entry has 3 values: Red, Green, Blue

    Mutable struct allows to use inplace methods

"""
mutable struct HdrImage
    width::Int
    height::Int
    pixels::Matrix{RGB}

    function HdrImage(width, height)  # defaul constructor
        pixels = Matrix{RGB}(undef, height, width)
        new(width, height, pixels)
    end

    function HdrImage(pixel_data, width, height)  # Constructor with data
        if length(pixel_data) != width * height * 3
            throw(ArgumentError("Number of elements of pixel_data doesn't match width * height * 3"))
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

"""
function print_image(img::HdrImage)
    print image dimensions and pixels in RGB representation
""" 
function print_image(img::HdrImage)
    println("Image pixels $(img.height)x$(img.width):")
    println(img)
end

"""
function valid_pixel(img::HdrImage, column, line)
    checks if pixels[column, line] exists
"""
function valid_pixel(img::HdrImage, column, line)
    return line >= 1 && line <= img.height && column >= 1 && column <= img.width
end

"""
function Base.:*(c1::RGB, c2::RGB)
    dot product between two colors
"""
function Base.:*(c1::RGB, c2::RGB)
    return RGB(c1.r*c2.r, c1.g*c2.g, c1.b*c2.b)
end

"""
function is_close(color1, color2, epsilon=1e-6)
    checks if two RGB color are similar
"""
function is_close(color1::RGB, color2::RGB, epsilon=1e-6)
    return abs(color1.r - color2.r) <= epsilon && abs(color1.g - color2.g) <= epsilon && abs(color1.b - color2.b) <= epsilon #Return True if the two variables are similiar, False otherwise
end
###PFM FUNCTIONS

#Error definition
"""
throws a message if PFM file reading is incorrect
"""
struct InvalidPfmFileFormat <: Exception
    msg::String
end

"""
function _read_float(io::IO, endianness)
    converts binary into floating point
    Checks if it is big or little endian (default is little)
"""
function _read_float(io::IO, endianness)
    try
        raw = read(io, UInt32)  #Reads 4 byte as UInt32
        if endianness > 0
            raw = bswap(raw)  #If big-endian, inverts bytes
        end
        return reinterpret(Float32, raw)  #Convert into Float32
    catch
        throw(InvalidPfmFileFormat("Invalid float number"))
    end
end

"""
function _read_line(io:IO)
    reads a single pfm line, until finds "\n"
    saves as a string
"""
function _read_line(io::IO)
    result = UInt8[] 
    while !eof(io)
        cur_byte = read(io, UInt8)  #Read single byte
        if cur_byte == 0x0A  #Check if it's "\n"
            if length(result) == 0 #Error if it's empty line
                throw(InvalidPfmFileFormat("Empty line"))
            end
            return String(result)  #Convert byte into string
        end
        push!(result, cur_byte)  #add byte
    end
    return String(result)
end

"""
function _parse_img_size(line)
    reads image dimensions, checking if they are two positive integers
"""
function _parse_img_size(line)
    elements = split(line, " ")  #Split string
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

"""
function _parse_endianness(endian)
    reads pfm file endianness, -1 or 1
"""
function _parse_endianness(endian)

    value = try
        parse(Float64, endian) #Try to read endianness as a float
    catch
        throw(InvalidPfmFileFormat("Unable to read endianness")) #Print error if it is not a float
    end

    if value==0.0 || value===NaN
        throw(InvalidPfmFileFormat("Endiannes = 0 or NaN")) #Print error if it's 0 or NaN
    end

    return value
end

"""
function read_pfm(filename)
    function that reads a pfm file and returns file format, dimensions, endianness and image data in a matrix
"""
function read_pfm(filename)
    open(filename, "r") do io
        format = _read_line(io)  #"Pf" or "PF"
        width, height = _parse_img_size(_read_line(io))  #dimensions
        endianness = _parse_endianness(_read_line(io))  #Reads eventual scale value
        
        # read pixels
        pixel_data = [ _read_float(io, endianness) for _ in 1:(3 * width * height) ]
       
        return format, width, height, endianness, pixel_data
    end
end

#####################################################################

# PFM WRITING

"""
function write_pfm_image(io::IO, img::HdrImage, endianness::Bool=true)

    Write a PFM file from an HdrImage.

    io::IO --> output buffer
    img::HdrImage -->  HDR image that has to be converted in a PFM file
    endianness::Bool --> endianness (default is little-endian)
"""
function write(io::IO, img::HdrImage, endianness::Bool=true)
    endian_str = endianness ? "-1.0" : "1.0"
    header = string("PF\n", img.width, " ", img.height, "\n", endian_str, "\n")

    try
        write(io, header)
    catch
        throw(InvalidPfmFileFormat("Invalid output file"))
    end

    for row_pixel in img.height:-1:1  # bottom-to-top
        for col_pixel in 1:img.width  # left-to-right
            color = img.pixels[row_pixel, col_pixel]
            _write_float!(io, color.r, endianness)
            _write_float!(io, color.g, endianness)
            _write_float!(io, color.b, endianness)
        end
    end
    
end

"""
function write_float!(io::IO, f, endianness::Bool=true)

    inplace method that writes a Float32 in the buffer

    io::IO --> output buffer
    f --> float value to write
    endianness::Bool --> endianness (default is little-endian)
"""
function _write_float!(io::IO, f, endianness::Bool=true)
    data = reinterpret(UInt32, Float32(f))  # Assicura che sia Float32
    data = endianness ? data : ntoh(data)   # Converte se necessario
    write(io, data)
end
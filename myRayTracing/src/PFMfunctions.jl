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
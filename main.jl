using Pkg
Pkg.activate("myRayTracing")
using myRayTracing #Fino a qua non toccare che serve a importare classi e librerie correttamente

format, width, height, endianness, pixel_data = _read_pfm("/home/davide/Fotorealistiche/reference_le.pfm")

println(format, "\n", width, "\n", height, "\n", endianness)
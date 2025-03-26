using Pkg
Pkg.activate("myRayTracing")
using Images
using myRayTracing #Fino a qua non toccare che serve a importare classi e librerie correttamente

format, width, height, endianness, pixel_data = _read_pfm("./memorial.pfm")

img = HdrImage(pixel_data, width, height)

save("./memorial.png", map(clamp01nan, img.pixels))
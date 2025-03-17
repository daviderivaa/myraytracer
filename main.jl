using Pkg
Pkg.activate("myRayTracing")
using myRayTracing #Fino a qua non toccare che serve a importare classi e librerie correttamente

# Crea un'immagine 2x3
img = HdrImage(2, 3)
rosso = Color(1.0, 1.0, 0.0)
verde = Color(0.0, 1.0, 0.0)

@assert valid_pixel(img, 2, 3) #Provo in un verso e nell'altro la funzione valid_pixel
@assert !valid_pixel(img, 2, 4)

# Colora il secondo pixel (posizione (1,2)) con un colore specifico somma di rosso e verde
img.pixels[1,2] = add(rosso, verde)

# Stampa i colori dei pixel dell'immagine
print_image(img)
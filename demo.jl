#DEMO PROJECT

using Pkg
Pkg.activate("myRayTracing")
using Images
using Colors
using myRayTracing

include("pfm2png.jl")

w = World()

coords = [-0.5,0.5]
for x in coords, y in coords, z in coords
    trasl = traslation(Vec(x,y,z)) #put sphere in the correct position
    s = Sphere(trasl(scaling(0.1))) #creates a sphere with radius = 0.1
    add_shape!(w, s)
end

trasl1 = traslation(Vec(0.0, 0.0, -0.5))
trasl2 = traslation(Vec(0.0, 0.5, 0.0))
s1 = Sphere(trasl1(scaling(0.1)))
s2 = Sphere(trasl2(scaling(0.1)))
add_shape!(w,s1)
add_shape!(w,s2)

PC = PerspectiveCamera(-1.0, 16.0/9.0, traslation(Vec(1.0, 0.0, 0.0)))
img = HdrImage(1600,900)
ITC = ImageTracer(img, PC)

function func(ray)
    if ray_intersection(w, ray) !== nothing
        return RGB(1.0, 1.0, 1.0)
    else
        return RGB(0.0, 0.0, 0.0)
    end
end

fire_all_rays!(ITC, func)

open("./demo_perspective.pfm", "w") do io
    write_pfm(io, ITC.img)
end

convert_pfm_to_png("./demo_perspective.pfm","demo_perspective")

#format, width, height, endianness, pixel_data = read_pfm("./demo_perspective.pfm")
#alpha, gamma, output_file_name, output_file_format = read_user_input()

#image = HdrImage(pixel_data, width, height)

#tone_mapping!(image, alpha)
#gamma_correction!(image, gamma)

#complete_output_file_name = "$(output_file_name)_g$(gamma)a$(alpha).$(output_file_format)"
#save("./" * complete_output_file_name, image.pixels)
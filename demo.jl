#DEMO PROJECT

using Pkg
Pkg.activate("myRayTracing")
using Images
using Colors
using myRayTracing

include("pfm2png.jl")

#Error definition
"""
throws a message if ARGS is incorrect
"""
struct InvalidARGS <: Exception
    msg::String
end


if length(ARGS) != 1
    throw(InvalidARGS("Required julia demo.jl <camera_type>\nWrite perspective or orthogonal"))
end


if ARGS[1] == "perspective"
    pfm_filename_and_path = "./demo/demo_perspective.pfm"
    filename = "demo_perspective"
    rot1 = rotation("z", π/6)
    Cam = PerspectiveCamera(-1.0, 16.0/9.0, rot1(traslation(Vec(1.0, 0.0, 0.0))))

elseif ARGS[1] == "orthogonal"
    pfm_filename_and_path = "./demo/demo_orthogonal.pfm"
    filename = "demo_orthogonal"
    rot1 = rotation("z", -π/15)
    rot2 = rotation("y", -π/18)
    Cam = OrthogonalCamera(16.0/9.0, rot1(rot2(traslation(Vec(-2.0, 0.0, 0.0)))))

else
    throw(InvalidARGS("Error in ARGS: in <camera_type> write perspective or orthogonal"))
end

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

img = HdrImage(1600,900)
IT = ImageTracer(img, Cam)

function func(ray)
    if ray_intersection(w, ray) !== nothing
        return RGB(1.0, 1.0, 1.0)
    else
        return RGB(0.0, 0.0, 0.0)
    end
end

fire_all_rays!(IT, func)

open(pfm_filename_and_path, "w") do io
    write_pfm(io, IT.img)
end

convert_pfm_to_png(pfm_filename_and_path,filename)

#format, width, height, endianness, pixel_data = read_pfm("./demo_perspective.pfm")
#alpha, gamma, output_file_name, output_file_format = read_user_input()

#image = HdrImage(pixel_data, width, height)

#tone_mapping!(image, alpha)
#gamma_correction!(image, gamma)

#complete_output_file_name = "$(output_file_name)_g$(gamma)a$(alpha).$(output_file_format)"
#save("./" * complete_output_file_name, image.pixels)
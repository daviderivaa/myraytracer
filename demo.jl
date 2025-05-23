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


if length(ARGS) != 2
    throw(InvalidARGS("Required julia demo.jl <camera_type> <angle>      <camera_type>: perspective or orthogonal    <angle>: rotation around z axis (in deg)"))
end

if ARGS[1] == "perspective"
    path = "./demo/"
    pfm_filename_and_path = "./demo/demo_perspective_" * ARGS[2] * ".pfm"
    filename = "demo_perspective_" * ARGS[2]
    angle = parse(Float64, ARGS[2])
    rot1 = rotation("z", -angle*π/180.0)
    Cam = PerspectiveCamera(-1.0, 16.0/9.0, rot1(traslation(Vec(1.0, 0.0, 0.0))))

elseif ARGS[1] == "orthogonal"
    path = "./demo/"
    pfm_filename_and_path = "./demo/demo_orthogonal_" * ARGS[2] * ".pfm"
    filename = "demo_orthogonal_" * ARGS[2]
    angle = parse(Float64, ARGS[2])
    rot1 = rotation("z", -angle*π/180.0)
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
add_shape!(w, s1)
add_shape!(w, s2)

img = HdrImage(1600,900)
IT = ImageTracer(img, Cam)

function func(ray)
    if ray_intersection(w, ray) !== nothing
        return RGB(1.0, 1.0, 1.0) # White
    else
        return RGB(0.0, 0.0, 0.0) # Black
    end
end

fire_all_rays!(IT, func)

# write pfm file
open(pfm_filename_and_path, "w") do io
    write_pfm(io, IT.img)
end

convert_pfm_to_png(path, pfm_filename_and_path, filename)
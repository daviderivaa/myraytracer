#DEMO PROJECT

using Pkg
Pkg.activate("../myRayTracing")
using Images
using Colors
using myRayTracing

include("../pfm2png.jl")

#Error definition
"""
throws a message if ARGS is incorrect
"""
struct InvalidARGS <: Exception
    msg::String
end


if length(ARGS) != 3
    throw(InvalidARGS("Required julia demo.jl <camera_type> <angle> <w_colors>     <camera_type>: perspective or orthogonal     <angle>: rotation around z axis (in deg)      <w_colors>: write yes or no for colored spheres"))
end

if ARGS[1] == "perspective"
    path = "../demo/"
    pfm_filename_and_path = "../demo/demo_perspective_" * ARGS[2] * ".pfm"
    filename = "demo_perspective_" * ARGS[2]
    angle = parse(Float64, ARGS[2])
    rot1 = rotation("z", angle*π/180.0)
    Cam = PerspectiveCamera(6.0, 16.0/9.0, rot1(translation(Vec(-1.0, 0.0, 0.0))))

elseif ARGS[1] == "orthogonal"
    path = "../demo/"
    pfm_filename_and_path = "../demo/demo_orthogonal_" * ARGS[2] * ".pfm"
    filename = "demo_orthogonal_" * ARGS[2]
    angle = parse(Float64, ARGS[2])
    rot1 = rotation("z", angle*π/180.0)
    rot2 = rotation("y", π/18)
    Cam = OrthogonalCamera(16.0/9.0, rot1(rot2(translation(Vec(-2.0, 0.0, 0.0)))))

else
    throw(InvalidARGS("Error in ARGS: in <camera_type> write perspective or orthogonal"))
end

w = World()

coords = [-0.5,0.5]
for x in coords, y in coords, z in coords
    trasl = translation(Vec(x,y,z)) #put sphere in the correct position
    if ARGS[2] == "no"
        s = Sphere(trasl(scaling(0.1))) #creates a sphere with radius = 0.1
    elseif ARGS[2] =="yes"
        s = Sphere(trasl(scaling(0.1)), Material(DiffuseBRDF(UniformPigment(RGB(1.0, 1.0, 1.0))), UniformPigment(RGB(1.0, 1.0, 1.0))))
    else
        throw(InvalidARGS("Invalid <w_colors> argument: write yes or no for colored spheres"))
    end

    add_shape!(w, s)
end

trasl1 = translation(Vec(0.0, 0.0, -0.5))
trasl2 = translation(Vec(0.0, 0.5, 0.0))

if ARGS[2] == "no"

    s1 = Sphere(trasl1(scaling(0.1)))
    s2 = Sphere(trasl2(scaling(0.1)))
    add_shape!(w,s1)
    add_shape!(w,s2)

elseif ARGS[2] == "yes"

    pig1 = CheckeredPigment(RGB(1.0, 1.0, 1.0), RGB(0.0, 0.0, 1.0), 10)
    pig2 = UniformPigment(RGB(0.1, 0.0, 1.0))

    s1 = Sphere(translation(Vec(0.0, 0.01, 0.0))(scaling(0.1)), Material(DiffuseBRDF(pig1),pig1))
    s2 = Sphere(translation(Vec(0.0, -0.01, 0.0))(scaling(0.1)), Material(DiffuseBRDF(pig2), pig2))

    u1 = union_shape(s1, s2, trasl1)
    u2 = union_shape(s1, s2, trasl2)
    add_shape!(w,u1)
    add_shape!(w,u2)

else
    throw(InvalidARGS("Invalid <w_colors> argument: write yes or no for colored spheres"))
end
    

img = HdrImage(1600,900)
IT = ImageTracer(img, Cam)

function func(ray)
    if ray_intersection(w, ray) !== nothing
        return RGB(1.0, 1.0, 1.0) # White
    else
        return RGB(0.0, 0.0, 0.0) # Black
    end
end

RND = FlatRenderer(w)

if ARGS[2] == "no"
    fire_all_rays!(IT, func) 
elseif ARGS[2] == "yes"
    fire_all_rays!(IT, RND) 
else
    throw(InvalidARGS("Invalid <w_colors> argument: write yes or no for colored spheres"))
end

#write pfm file
open(pfm_filename_and_path, "w") do io
    write_pfm(io, IT.img)
end

convert_pfm_to_png(path,pfm_filename_and_path,filename)
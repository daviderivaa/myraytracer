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
    throw(InvalidARGS("Required julia check_csg.jl <camera_type> <angle>      <camera_type>: perspective or orthogonal    <angle>: rotation around z axis (in deg)"))
end

if ARGS[1] == "perspective"
    path = "./CSG/"
    pfm_filename_and_path = "./CSG/csg_perspective_" * ARGS[2] * ".pfm"
    filename = "csg_perspective_" * ARGS[2]
    angle = parse(Float64, ARGS[2])
    rot1 = rotation("z", -angle*π/180.0)
    Cam = PerspectiveCamera(-1.0, 16.0/9.0, rot1(traslation(Vec(1.0, 0.0, 0.0))))

elseif ARGS[1] == "orthogonal"
    path = "./CSG/"
    pfm_filename_and_path = "./CSG/csg_orthogonal_" * ARGS[2] * ".pfm"
    filename = "csg_orthogonal_" * ARGS[2]
    angle = parse(Float64, ARGS[2])
    rot1 = rotation("z", -angle*π/180.0)
    rot2 = rotation("y", -π/18)
    Cam = OrthogonalCamera(16.0/9.0, rot1(rot2(traslation(Vec(-2.0, 0.0, 0.0)))))

else
    throw(InvalidARGS("Error in ARGS: in <camera_type> write perspective or orthogonal"))
end

w = World()

color1 = RGB(1.0, 0.0, 0.0) #RED 
color2 = RGB(0.0, 1.0, 0.0) #GREEN
color3 = RGB(0.0, 0.0, 1.0) #BLUE
color4 = RGB(0.0, 1.0, 1.0) #CYAN
color5 = RGB(0.1, 0.0, 1.0) #PURPLE

pig1 = CheckeredPigment(RGB(0.0, 0.0, 0.0), color3, 30)
pig2 = CheckeredPigment(RGB(0.0, 0.0, 0.0), color1, 30)

material1 = Material(DiffuseBRDF(pig1, 0.5), pig1)
material2 = Material(DiffuseBRDF(pig2, 0.5), pig2)

s1 = Sphere(traslation(Vec(0.5, 0.12, 0.0))(scaling(0.3)), material1) #creates a sphere with radius = 0.1
s2 = Sphere(traslation(Vec(0.5, -0.12, 0.0))(scaling(0.3)), material2)

U = union_shape(s1, s2, traslation(Vec(0.0, 1.0, 0.0)))
I = intersec_shape(s1, s2)
D = diff_shape(s1, s2, traslation(Vec(0.0, -1.0, 0.0)))

add_shape!(w, U)
add_shape!(w, I)
add_shape!(w, D)

img = HdrImage(1600,900)
IT = ImageTracer(img, Cam)

RND = OnOffRenderer(w, RGB(0.0, 0.0, 0.0), RGB(0.0, 0.0, 1.0))
RND2 = FlatRenderer(w)

fire_all_rays!(IT, RND2)

open(pfm_filename_and_path, "w") do io
    write_pfm(io, IT.img)
end

convert_pfm_to_png(path, pfm_filename_and_path, filename)
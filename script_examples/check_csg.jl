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
    throw(InvalidARGS("Required julia check_csg.jl <camera_type> <angle_z> <angle_y>     <camera_type>: perspective or orthogonal    <angle_z>: rotation around z axis (in deg)     <angle_y>: rotation around z axis (in deg)"))
end

if ARGS[1] == "perspective"
    path = "../CSG/"
    pfm_filename_and_path = "../CSG/csg_perspective_z" * ARGS[2] * "_y" * ARGS[3] * ".pfm"
    filename = "csg_perspective_z" * ARGS[2] * "_y" * ARGS[3]
    angle_z = parse(Float64, ARGS[2])
    angle_y = parse(Float64, ARGS[3])
    rot1 = rotation("z", angle_z*π/180.0)
    rot2 = rotation("y", angle_y*π/180.0)
    Cam = PerspectiveCamera(2.0, 16.0/9.0, rot1(rot2(translation(Vec(-1.0, 0.0, 0.0)))))

elseif ARGS[1] == "orthogonal"
    path = "../CSG/"
    pfm_filename_and_path = "../CSG/csg_orthogonal_z" * ARGS[2] * "_y" * ARGS[3] * ".pfm"
    filename = "csg_orthogonal_z" * ARGS[2] * "_y" * ARGS[3]
    angle_z = parse(Float64, ARGS[2])
    angle_y = parse(Float64, ARGS[3])
    rot1 = rotation("z", angle_z*π/180.0)
    rot2 = rotation("y", angle_y*π/180.0)
    Cam = OrthogonalCamera(16.0/9.0, rot1(rot2(translation(Vec(-2.0, 0.0, 0.3)))))

else
    throw(InvalidARGS("Error in ARGS: in <camera_type> write perspective or orthogonal"))
end

w = World()

color1 = RGB(1.0, 0.0, 0.0) #RED 
color2 = RGB(0.0, 1.0, 0.0) #GREEN
color3 = RGB(0.0, 0.0, 1.0) #BLUE

material1 = Material(DiffuseBRDF(UniformPigment(color1)))
material2 = Material(DiffuseBRDF(UniformPigment(color2)))
material3 = Material(DiffuseBRDF(UniformPigment(color3)))

material4 = Material(DiffuseBRDF(CheckeredPigment(RGB(1.0, 1.0, 1.0), color3)))

s = Sphere(translation(Vec(0.0, 0.0, 0.0))(scaling(0.65)), material3) 
b = Box(1.0, 1.0, 1.0, translation(Vec(-0.5, -0.5, -0.5)), material1)
I1 = intersec_shape(b, s, translation(Vec(0.0, 0.0, 0.0)))

c1 = Cylinder(0.3, 1.05, translation(Vec(-0.5, 0.0, 0.5))(rotation("y", π/2)), material2)
c2 = Cylinder(0.3, 1.05, translation(Vec(0.0, 0.0, 0.0)), material2)
c3 = Cylinder(0.3, 1.05, rotation("z", π/2)(translation(Vec(-0.5, 0.0, 0.0))(rotation("y", π/2))), material2)
U1 = union_shape(c1, c2, translation(Vec(0.0, 0.0, -0.5)))
U2 = union_shape(U1, c3)

D = diff_shape(I1, U2)

p = Plane(translation(Vec(0.0, 0.0, -1.5)), material4)

add_shape!(w, D)
add_shape!(w, p)

img = HdrImage(1600,900)
IT = ImageTracer(img, Cam)

RND = OnOffRenderer(w, RGB(0.0, 0.0, 0.0), RGB(0.0, 0.0, 1.0))
RND2 = FlatRenderer(w)

fire_all_rays!(IT, RND2)

open(pfm_filename_and_path, "w") do io
    write_pfm(io, IT.img)
end

convert_pfm_to_png(path, pfm_filename_and_path, filename, 0.7)

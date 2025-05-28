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

if length(ARGS) != 3
    throw(InvalidARGS("Required julia box.jl <camera_type> <angle_z> <angle_y>     <camera_type>: perspective or orthogonal    <angle_z>: rotation around z axis (in deg)     <angle_y>: rotation around z axis (in deg)"))
end

if ARGS[1] == "perspective"
    path = "./CSG/"
    pfm_filename_and_path = "./CSG/box_perspective_z" * ARGS[2] * "_y" * ARGS[3] * ".pfm"
    filename = "box_perspective_z" * ARGS[2] * "_y" * ARGS[3]
    angle_z = parse(Float64, ARGS[2])
    angle_y = parse(Float64, ARGS[3])
    rot1 = rotation("z", angle_z*π/180.0)
    rot2 = rotation("y", angle_y*π/180.0)
    Cam = PerspectiveCamera(1.0, 16.0/9.0, rot1(rot2(traslation(Vec(1.0, 0.0, 0.0)))))

elseif ARGS[1] == "orthogonal"
    path = "./CSG/"
    pfm_filename_and_path = "./CSG/box_orthogonal_z" * ARGS[2] * "_y" * ARGS[3] * ".pfm"
    filename = "box_orthogonal_z" * ARGS[2] * "_y" * ARGS[3]
    angle_z = parse(Float64, ARGS[2])
    angle_y = parse(Float64, ARGS[3])
    rot1 = rotation("z", angle_z*π/180.0)
    rot2 = rotation("y", angle_y*π/180.0)
    Cam = OrthogonalCamera(16.0/9.0, rot1(rot2(traslation(Vec(-2.0, 0.0, 0.3)))))

else
    throw(InvalidARGS("Error in ARGS: in <camera_type> write perspective or orthogonal"))
end

w = World()

color1 = RGB(1.0, 0.0, 0.0) #RED 
color2 = RGB(0.0, 1.0, 0.0) #GREEN
color3 = RGB(0.0, 0.0, 1.0) #BLUE
color4 = RGB(0.0, 1.0, 1.0) #CYAN
color5 = RGB(0.1, 0.0, 1.0) #PURPLE

pig1 = CheckeredPigment(RGB(1.0, 1.0, 1.0), color3, 10)
pig2 = CheckeredPigment(RGB(1.0, 1.0, 1.0), color1, 10)
pig3 = CheckeredPigment(RGB(1.0, 1.0, 1.0), color2, 10)
pig4 = CheckeredPigment(RGB(1.0, 1.0, 1.0), color5, 10)
pig5 = CheckeredPigment(RGB(0.0, 0.0, 0.0), color3, 10)

material1 = Material(DiffuseBRDF(pig1, 0.5), pig1)
material2 = Material(DiffuseBRDF(pig2, 0.5), pig2)
material3 = Material(DiffuseBRDF(pig3, 0.5), pig3)
material4 = Material(DiffuseBRDF(pig4, 0.5), pig4)
material5 = Material(DiffuseBRDF(pig5, 0.5), pig5)

s1 = Sphere(traslation(Vec(0.1, 0.0, 0.5))(scaling(0.3)), material5) #creates a sphere with radius = 0.1
s2 = Sphere(traslation(Vec(0.5, -0.12, 0.0))(scaling(0.3)), material2)

r1 = Rectangle(Point(-0.5, -0.5, 0.0), Vec(1.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), traslation(Vec(0.0, 0.0, 0.1)), material3) #Rectangle
r2 = Rectangle(Point(-0.5, -0.5, 0.0), Vec(0.0, 0.0, 1.0), Vec(0.0, 1.0, 0.0), traslation(Vec(0.0, 0.0, 0.1)), material1) #Rectangle
r3 = Rectangle(Point(-0.5, -0.5, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0), traslation(Vec(0.0, 0.0, 1.1)), material3) #Rectangle
r4 = Rectangle(Point(-0.5, -0.5, 0.0), Vec(1.0, 0.0, 0.0), Vec(0.0, 0.0, 1.0), traslation(Vec(0.0, 0.0, 0.1)), material2) #Rectangle
r5 = Rectangle(Point(-0.5, -0.5, 0.0), Vec(1.0, 0.0, 0.0), Vec(0.0, 0.0, 1.0), traslation(Vec(0.0, 1.0, 0.1)), material2) #Rectangle
p1 = Plane(traslation(Vec(0.0, 0.0, -1.0)), material4) #plane

add_shape!(w, s1)
add_shape!(w, r1)
add_shape!(w, r2)
add_shape!(w, r3)
add_shape!(w, r4)
add_shape!(w, r5)
add_shape!(w, p1)

img = HdrImage(1600,900)
IT = ImageTracer(img, Cam)

RND = OnOffRenderer(w, RGB(0.0, 0.0, 0.0), RGB(0.0, 0.0, 1.0))
RND2 = FlatRenderer(w)

fire_all_rays!(IT, RND2)

open(pfm_filename_and_path, "w") do io
    write_pfm(io, IT.img)
end

convert_pfm_to_png(path, pfm_filename_and_path, filename)
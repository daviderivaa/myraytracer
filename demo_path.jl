#DEMO PROJECT

using Pkg
Pkg.activate("myRayTracing")
using Images
using Colors
using myRayTracing
using LinearAlgebra

include("pfm2png.jl")

#Error definition
"""
throws a message if ARGS is incorrect
"""
struct InvalidARGS <: Exception
    msg::String
end

if length(ARGS) != 3
    throw(InvalidARGS("Required julia demo_path.jl <camera_type> <angle_z> <angle_y>     <camera_type>: perspective or orthogonal    <angle_z>: rotation around z axis (in deg)     <angle_y>: rotation around z axis (in deg)"))
end

if ARGS[1] == "perspective"
    path = "./demo_path/"
    pfm_filename_and_path = "./demo_path/demo_path_perspective_z" * ARGS[2] * "_y" * ARGS[3] * ".pfm"
    filename = "demo_path_perspective_z" * ARGS[2] * "_y" * ARGS[3]
    angle_z = parse(Float64, ARGS[2])
    angle_y = parse(Float64, ARGS[3])
    rot1 = rotation("z", angle_z*π/180.0)
    rot2 = rotation("y", angle_y*π/180.0)
    Cam = PerspectiveCamera(-1.0, 16.0/9.0, rot1(rot2(traslation(Vec(1.0, 0.0, 0.0)))))

elseif ARGS[1] == "orthogonal"
    path = "./demo_path/"
    pfm_filename_and_path = "./demo_path/demo_path_orthogonal_z" * ARGS[2] * "_y" * ARGS[3] * ".pfm"
    filename = "demo_path_orthogonal_z" * ARGS[2] * "_y" * ARGS[3]
    angle_z = parse(Float64, ARGS[2])
    angle_y = parse(Float64, ARGS[3])
    rot1 = rotation("z", angle_z*π/180.0)
    rot2 = rotation("y", angle_y*π/180.0)
    Cam = OrthogonalCamera(16.0/9.0, rot1(rot2(traslation(Vec(-2.0, 0.0, 0.3)))))

else
    throw(InvalidARGS("Error in ARGS: in <camera_type> write perspective or orthogonal"))
end

w = World()

s = Sphere(scaling(0.3), Material(SpecularBRDF(UniformPigment(RGB(1.0,0.0,0.0)))))
p = Plane(Transformation(Matrix{Float64}(I(4))), Material(DiffuseBRDF(CheckeredPigment())))
add_shape!(w, s)
add_shape!(w, p)

img = HdrImage(1600,900)
IT = ImageTracer(img, Cam)

RND = PathTracer(w, RGB(0.0,0.5,1.0))

println("1\n")

fire_all_rays!(IT, RND)

println("2\n")

open(pfm_filename_and_path, "w") do io
    write_pfm(io, IT.img)
end

convert_pfm_to_png(path, pfm_filename_and_path, filename)
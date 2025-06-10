#DEMO PROJECT

using Pkg
Pkg.activate("../myRayTracing")
using Images
using Colors
using myRayTracing
using Profile
using PProf

include("../pfm2png.jl")

#Error definition
"""
throws a message if ARGS is incorrect
"""
struct InvalidARGS <: Exception
    msg::String
end

if length(ARGS) < 3 || length(ARGS) > 4
    throw(InvalidARGS("Required julia demo_path.jl <camera_type> <angle_z> <angle_y> <profile(optional)>    <camera_type>: perspective or orthogonal    <angle_z>: rotation around z axis (in deg)     <angle_y>: rotation around z axis (in deg)"))
end

if ARGS[1] == "perspective"
    path = "../demo_path/"
    pfm_filename_and_path = "../demo_path/demo_path_perspective_z" * ARGS[2] * "_y" * ARGS[3] * ".pfm"
    filename = "demo_path_perspective_z" * ARGS[2] * "_y" * ARGS[3]
    angle_z = parse(Float64, ARGS[2])
    angle_y = parse(Float64, ARGS[3])
    rot1 = rotation("z", angle_z*π/180.0)
    rot2 = rotation("y", angle_y*π/180.0)
    Cam = PerspectiveCamera(2.0, 16.0/9.0, rot1(rot2(translation(Vec(-1.0, 0.0, 0.0)))))

elseif ARGS[1] == "orthogonal"
    path = "../demo_path/"
    pfm_filename_and_path = "../demo_path/demo_path_orthogonal_z" * ARGS[2] * "_y" * ARGS[3] * ".pfm"
    filename = "demo_path_orthogonal_z" * ARGS[2] * "_y" * ARGS[3]
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

format, width, height, endianness, pixel_data = read_pfm("../PFM_input/pigsky.pfm")

starsky = HdrImage(pixel_data, width, height)

pig1 = CheckeredPigment(RGB(1.0, 1.0, 1.0), color3, 10)
pigsky = ImagePigment(starsky)

material1 = Material(DiffuseBRDF(pig1, 0.5))

s = Sphere(translation(Vec(0.0, 0.0, -0.7))(scaling(0.3)), Material(SpecularBRDF(UniformPigment(RGB(1.0, 0.0, 0.0)))))
s1 = Sphere(translation(Vec(0.0, -1.3, -0.5))(scaling(0.5)), Material(SpecularBRDF(UniformPigment(RGB(1.0, 1.0, 0.0)))))
#sky = Sphere(scaling(15.0), Material(DiffuseBRDF(UniformPigment(RGB(0.58, 0.56, 0.6)), 0.0), UniformPigment(RGB(0.58, 0.56, 0.6))))
sky = Sphere(scaling(5.0)(rotation("z", π/4)), Material(DiffuseBRDF(pigsky), pigsky))
p2 = Plane(translation(Vec(0.0, 0.0, -1.0)), material1)

add_shape!(w, s)
add_shape!(w, s1)
add_shape!(w, sky)
add_shape!(w, p2)

img = HdrImage(1600,900)
IT = ImageTracer(img, Cam)

pcg = new_PCG()

RND = PathTracer(w, RGB(0.0, 0.0, 0.0), 2, 3, 2, pcg)

enable_profile = "--profile" in ARGS
if enable_profile
    @pprof fire_all_rays!(IT, RND, pcg, 5)
else
    val, t, bytes, gctime, gcstats = @timed fire_all_rays!(IT, RND, pcg, 5)
    println("Profiling fire_all_rays method:\nTime: $t s\nAllocated memory: $(bytes/1_000_000) MB\nGC: $gctime s")
    println("For a complete profiling use --profile flag")
end

open(pfm_filename_and_path, "w") do io
    write_pfm(io, IT.img)
end

convert_pfm_to_png(path, pfm_filename_and_path, filename, 0.5)
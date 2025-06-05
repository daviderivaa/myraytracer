#MAIN PROJECT

using Pkg
Pkg.activate("myRayTracing")
using Images
using Colors
using myRayTracing
using LinearAlgebra
using Profile
using PProf

include("pfm2png.jl")

#Error definition
"""
throws a message if ARGS is incorrect
"""
struct InvalidARGS <: Exception
    msg::String
end

if length(ARGS) < 1 || length(ARGS) > 2
    throw(InvalidARGS("Required julia main.jl <text file> <profile(optional)>"))
end

txt_file = "./examples/" * ARGS[1] * ".txt"

function read_txt(file_in)
    open(file_in, "r") do file
        input = InputStream(file)
        #params = Dict{String, Float64}()
        return parse_scene(input)
    end
end
scene = read_txt(txt_file)

println("Scene parsed successfully!")

path = "./demo_scene/"
pfm_filename_and_path = "./demo_scene/demo_scene" * ".pfm"
filename = "demo_scene"
Cam = scene.camera

w = scene.world

img = HdrImage(1600,900)
IT = ImageTracer(img, Cam)

pcg = new_PCG()

RND = PathTracer(w, RGB(0.0, 0.0, 0.0), pcg, 2, 3, 2)

enable_profile = "--profile" in ARGS
if enable_profile
    @pprof fire_all_rays!(IT, RND, pcg, 2)
else
    val, t, bytes, gctime, gcstats = @timed fire_all_rays!(IT, RND, pcg, 2)
    println("Profiling fire_all_rays method:\nTime: $t s\nAllocated memory: $(bytes/1_000_000) MB\nGC: $gctime s")
    println("For a complete profiling use --profile flag")
end

open(pfm_filename_and_path, "w") do io
    write_pfm(io, IT.img)
end

convert_pfm_to_png(path, pfm_filename_and_path, filename, 0.5)
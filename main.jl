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
    throw(InvalidARGS("Required julia main.jl <text filename> <profile(optional)>"))
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

path = "./examples_img/"
pfm_filename_and_path = "./examples_img/" * ARGS[1] * ".pfm"
filename = ARGS[1]
Cam = scene.camera

w = scene.world

img = HdrImage(1600,900)
IT = ImageTracer(img, Cam)

if isnothing(scene.renderer)
    println("Calling default renderer: PathTracer(\n 
                                    b_color::RGB = RGB(0.0, 0.0, 0.0),\n
                                    num_rays = 2,\n
                                    max_depth = 3,\n 
                                    rr_limit = 2,\n 
                                    pcg = new_PCG()\n
                                    )")
    RND = PathTracer(w)
else
    RND = scene.renderer
end

pcg = new_PCG(UInt64(78), UInt64(24)) #for antialiasing

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
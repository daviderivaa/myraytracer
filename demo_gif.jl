#DEMO PROJECT

using Pkg
Pkg.activate("myRayTracing")
using Images
using Colors
using myRayTracing
using ImageMagick, FileIO
using VideoIO, Images

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

# rotate cube around z axis by 360 deg angle
for angle in 0:360
    if ARGS[1] == "perspective"
        idx_angle = lpad(string(angle), 3, '0')
        path = "./demo/"
        pfm_filename_and_path = "./demo/demo_perspective_" * idx_angle * ".pfm"
        filename = "demo_perspective_" * idx_angle
        rot1 = rotation("z", -angle*π/180.0)
        Cam = PerspectiveCamera(-1.0, 16.0/9.0, rot1(traslation(Vec(1.0, 0.0, 0.0))))

    elseif ARGS[1] == "orthogonal"
        idx_angle = lpad(string(angle), 3, '0')
        path = "./demo/"
        pfm_filename_and_path = "./demo/demo_orthogonal_" * idx_angle * ".pfm"
        filename = "demo_orthogonal_" * (idx_angle)
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
    add_shape!(w,s1)
    add_shape!(w,s2)

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

    #write pfm file
    open(pfm_filename_and_path, "w") do io
        write_pfm(io, IT.img)
    end

    convert_pfm_to_png(path,pfm_filename_and_path,filename)
end

# sort png files
files = sort(filter(f -> endswith(f, ".png"), readdir("./demo/", join=true)))

for (i, file) in enumerate(files)
    # Add padding
    idx_str = lpad(string(i - 1), 3, '0') 
    
    # rename png file
    new_png_name = "./demo/img_$(idx_str).png"
    Base.rename(file, new_png_name)
    
    # rename pfm file
    pfm_file = replace(file, ".png" => ".pfm")
    new_pfm_name = "./demo/img_$(idx_str).pfm"
    if isfile(pfm_file)
        Base.rename(pfm_file, new_pfm_name)
    end
end


#GIF parameters
cmd = `ffmpeg -framerate 36 -i './demo/img_%03d.png' -vf "fps=36,scale=640:-1:flags=lanczos" -loop 0 $(ARGS[1] * ".gif")`

println("Executing: ", cmd)
run(cmd)

# Delete files
for (i, _) in enumerate(files)
    idx_str = lpad(string(i - 1), 3, '0')
    rm("./demo/img_$(idx_str).png")
    
    if ARGS[1] == "orthogonal"
        pfm_file = "./demo/demo_orthogonal_" * idx_str * ".pfm"
    elseif ARGS[1] == "perspective"
        pfm_file = "./demo/demo_perspective_" * idx_str * ".pfm"
    else
        throw(InvalidARGS("Error in ARGS: in <camera_type> write perspective or orthogonal"))
    end
    if isfile(pfm_file) 
        rm(pfm_file)
    end
end

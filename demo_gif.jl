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


if length(ARGS) != 2
    throw(InvalidARGS("Required julia demo.jl <camera_type> <w_colors> \n <camera_type>: write perspective or orthogonal \n <w_colors>: write yes or no for colored spheres"))
end

# rotate cube around z axis by 360 deg angle
for angle in 0:360
    if ARGS[1] == "perspective"
        idx_angle = lpad(string(angle), 3, '0')
        path = "./demo/"
        pfm_filename_and_path = "./demo/demo_perspective_" * idx_angle * ".pfm"
        filename = "demo_perspective_" * idx_angle
        rot1 = rotation("z", angle*π/180.0)
        Cam = PerspectiveCamera(6.0, 16.0/9.0, rot1(traslation(Vec(-1.0, 0.0, 0.0))))

    elseif ARGS[1] == "orthogonal"
        idx_angle = lpad(string(angle), 3, '0')
        path = "./demo/"
        pfm_filename_and_path = "./demo/demo_orthogonal_" * idx_angle * ".pfm"
        filename = "demo_orthogonal_" * (idx_angle)
        rot1 = rotation("z", angle*π/180.0)
        rot2 = rotation("y", π/18)
        Cam = OrthogonalCamera(16.0/9.0, rot1(rot2(traslation(Vec(-2.0, 0.0, 0.0)))))

    else
        throw(InvalidARGS("Error in ARGS: in <camera_type> write perspective or orthogonal"))
    end

    w = World()

    coords = [-0.5,0.5]
    for x in coords, y in coords, z in coords
        trasl = traslation(Vec(x,y,z)) #put sphere in the correct position
        if ARGS[2] == "no"
            s = Sphere(trasl(scaling(0.1))) #creates a sphere with radius = 0.1
        elseif ARGS[2] =="yes"
            s = Sphere(trasl(scaling(0.1)), Material(DiffuseBRDF(UniformPigment(RGB(1.0, 1.0, 1.0))), UniformPigment(RGB(1.0, 1.0, 1.0))))
        else
            throw(InvalidARGS("Invalid <w_colors> argument: write yes or no for colored spheres"))
        end

        add_shape!(w, s)
    end

    trasl1 = traslation(Vec(0.0, 0.0, -0.5))
    trasl2 = traslation(Vec(0.0, 0.5, 0.0))

    if ARGS[2] == "no"

        s1 = Sphere(trasl1(scaling(0.1)))
        s2 = Sphere(trasl2(scaling(0.1)))
        add_shape!(w,s1)
        add_shape!(w,s2)

    elseif ARGS[2] == "yes"

        pig1 = CheckeredPigment(RGB(1.0, 1.0, 1.0), RGB(0.0, 0.0, 1.0), 10)
        pig2 = UniformPigment(RGB(0.1, 0.0, 1.0))

        s1 = Sphere(traslation(Vec(0.0, 0.01, 0.0))(scaling(0.1)), Material(DiffuseBRDF(pig1),pig1))
        s2 = Sphere(traslation(Vec(0.0, -0.01, 0.0))(scaling(0.1)), Material(DiffuseBRDF(pig2), pig2))

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

if ARGS[2] == "no"
    cmd = `ffmpeg -framerate 36 -i './demo/img_%03d.png' -vf "fps=36,scale=640:-1:flags=lanczos" -loop 0 $(ARGS[1] * ".gif")`
elseif ARGS[2] == "yes"
    cmd = `ffmpeg -framerate 36 -i './demo/img_%03d.png' -vf "fps=36,scale=640:-1:flags=lanczos" -loop 0 $(ARGS[1] * "_c.gif")`
else
    throw(InvalidARGS("Invalid <w_colors> argument: write yes or no for colored spheres"))
end

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

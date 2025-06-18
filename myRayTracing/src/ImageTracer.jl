#IMAGE TRACER STRUCTS AND METHODS

using Base.Threads


#IMAGE TRACER STRUCT
"""
struct ImageTracer
    Creates an Image Tracer object with an HdrImage and a Camera
"""
struct ImageTracer

    img::HdrImage
    cam::Camera

    function ImageTracer(image::HdrImage, camera::Camera)
        new(image, camera)
    end

end

"""
function fire_ray(IT::ImageTracer, col, row, u_pixel=0.5, v_pixel=0.5)
    returns a modified ray

    u = (col-1 + u_pixel) / IT.img.width --> get the point on the screen witha given pixel
    v = 1.0 - (row-1 + v_pixel) / IT.img.height
    return fire_ray(IT.cam, u, v) --> return the ray
"""
function fire_ray(IT::ImageTracer, col, row, u_pixel=0.5, v_pixel=0.5)

    try
        u = (col-1 + u_pixel) / IT.img.width
        v = 1.0 - (row-1 + v_pixel) / IT.img.height
        return fire_single_ray(IT.cam, u, v)
    catch
        throw(Type_error("col and row are incorrect (either type or value out of range)"))
    end

end

"""
function fire_all_rays!(IT::ImageTracer, func)
    inplace method that fires all rays on the screen

    for row in 1:IT.img.height --> cicles on heigth and width
        for col in 1:IT.img.width
            ray = fire_ray(IT, col, row)
            color = func(ray)
            IT.img.pixels[col, row] = color --> sets the pixel color with a function "func"
        end
    end
"""
function fire_all_rays!(IT::ImageTracer, func, PCG=new_PCG(), aa_num_of_rays::Int64=0)

    if aa_num_of_rays == 0
        try 
            Threads.@threads for row in 1:IT.img.height
                for col in 1:IT.img.width
                    ray = fire_ray(IT, col, row)
                    color = func(ray)
                    IT.img.pixels[row, col] = color
                end
            end
        catch
            throw(Type_error("fire_all_rays! method not implemented for $(typeof(IT))"))
        end
    else
        if aa_num_of_rays < 0
            throw(Type_error("AntiAliasing number of rays can't be negative."))
        end
        Threads.@threads for row in 1:IT.img.height
            for col in 1:IT.img.width
                cum_color = RGB(0.0, 0.0, 0.0)
                for i in 1:aa_num_of_rays
                    for j in 1:aa_num_of_rays
                        u_pixel = (norm_random!(PCG) + (j-1)) / aa_num_of_rays
                        v_pixel = (norm_random!(PCG) + (i-1)) / aa_num_of_rays
                        ray = fire_ray(IT, col, row, u_pixel, v_pixel)
                        cum_color += func(ray)
                    end
                end
                IT.img.pixels[row, col] = cum_color / (aa_num_of_rays^2)
            end
        end
    end

end
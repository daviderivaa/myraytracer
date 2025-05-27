#IMAGE TRACER STRUCTS AND METHODS


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

    u = (col + u_pixel) / IT.img.width --> get the point on the screen witha given pixel
    v = 1.0 - (row + v_pixel) / IT.img.height
    return fire_ray(IT.cam, u, v) --> return the ray
"""
function fire_ray(IT::ImageTracer, col, row, u_pixel=0.5, v_pixel=0.5)

    try
        u = (col + u_pixel) / IT.img.width
        v = 1.0 - (row + v_pixel) / IT.img.height
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
function fire_all_rays!(IT::ImageTracer, func)

    try 
        for row in 1:IT.img.height
            for col in 1:IT.img.width
                ray = fire_ray(IT, col, row)
                color = func(ray)
                #color = func
                IT.img.pixels[row, col] = color
            end
            println(row)
        end
    catch
        throw(Type_error("fire_all_rays! method not implemented for $(typeof(IT))"))
    end

end
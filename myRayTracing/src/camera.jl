#Camera struct

#Defining an abstarct type with two substructs
"""Abstarct struct for cameras"""
abstract type Camera
end

"""Abstarct method for fire_ray"""
function fire_ray(cam::Camera, u, v)
    throw(Type_error("fire_ray method not implemented for $(typeof(cam))"))
end

#Defining substructs
#Orthogonal Camera
"""
struct OrthogonalCamera <: Camera
    Creates a Orthogonal Camera with its own aspect ratio and transformation

    aspect_ratio::Float64 --> aspect ratio of the screen
    transformation::Transformation --> transformation that leads to the point of view
"""
struct OrthogonalCamera <: Camera

    aspect_ratio::Float64
    transfromation::Transformation

    function OrthogonalCamera(aspect_ratio, transfromation::Transformation)
        new(aspect_ratio, transfromation)
    end

end

"""Shoot a ray through the camera screen
    u and v are the coordinates un the screen. (u,v)=(0,0) is the bottom left corner, (u,v)=(1,1) is the top right one"""
function fire_ray(cam::OrthogonalCamera, u, v)

    origin = Point(-1.0, (1.0 - 2 * u) * cam.aspect_ratio, 2 * v - 1.0)
    direction = Vec(1.0, 0.0, 0.0)
    #return cam.transformation*Ray(origin=origin, dir=direction)
    return Ray(origin, direction)

end

#Perspective Camera
"""Creates a Perspective Camera with its own origin, aspect ratio and transformation"""
struct PerspectiveCamera <: Camera

    distance::Float64
    aspect_ratio::Float64
    transformation::Transformation

    function PerspectiveCamera(distance, aspect_ratio, transformation::Transformation)
        new(distance, aspect_ratio, transformation)
    end

end

"""Shoot a ray through the camera screen
    u and v are the coordinates un the screen. (u,v)=(0,0) is the bottom left corner, (u,v)=(1,1) is the top right one"""
function fire_ray(cam::PerspectiveCamera, u, v)
    
    origin = Point(-cam.distance, 0.0, 0.0)
    direction = Vec(cam.distance, (1.0 - 2 * u) * cam.aspect_ratio, 2 * v - 1.0)
    return cam.transformation*Ray(origin, direction)

end

"""Compute the aperture of the camera in degrees

    The aperture is the angle of the field-of-view along the horizontal direction (Y axis)"""
function aperture_deg(cam::PerspectiveCamera)
    return 2.0 * math.atan(cam.distance / cam.aspect_ratio) * 180.0 / 3.14159265359
end
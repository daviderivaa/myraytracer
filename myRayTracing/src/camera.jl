#Camera struct

#Defining an abstarct type with two substructs
"""Abstarct struct for cameras"""
abstract type Camera
end

"""Abstarct method for fire_single_ray"""
function fire_single_ray(cam::Camera, u, v)
    throw(Type_error("fire_single_ray method not implemented for $(typeof(cam))"))
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
    transformation::Transformation

    function OrthogonalCamera(aspect_ratio, transformation::Transformation=Transformation(Matrix{Float64}(I(4))))
        if aspect_ratio <= 0.0
            throw(ArgumentError("aspect ratio has to be positive"))
        end
        new(aspect_ratio, transformation)
    end

end

"""
function fire_single_ray(cam::OrthogonalCamera, u, v)
    Shoot a ray through the camera screen, u and v are the coordinates un the screen. (u,v)=(0,0) is the bottom left corner, (u,v)=(1,1) is the top right one.

    origin = Point(-1.0, (1.0 - 2 * u) * cam.aspect_ratio, 2 * v - 1.0)
"""
function fire_single_ray(cam::OrthogonalCamera, u, v)

    origin = Point(-1.0, (1.0 - 2 * u) * cam.aspect_ratio, 2 * v - 1.0)
    direction = Vec(1.0, 0.0, 0.0)
    return cam.transformation(Ray(origin, direction))

end

#Perspective Camera
"""
struct PerspectiveCamera <: Camera
    Creates a Perspective Camera with its own origin, aspect ratio and transformation.

    distance::Float64 --> in the perspective camera you also have to specify the distance from the screen
    aspect_ratio::Float64 --> aspect ratio of the screen    
    transformation::Transformation --> transformation that leads to the point of view
"""
struct PerspectiveCamera <: Camera

    distance::Float64
    aspect_ratio::Float64
    transformation::Transformation

    function PerspectiveCamera(distance, aspect_ratio, transformation::Transformation)
        if distance <= 0.0 || aspect_ratio <= 0.0
            throw(ArgumentError("both distance and aspect ratio have to be positive")) 
        end
        new(distance, aspect_ratio, transformation)
    end

end

"""
function fire_single_ray(cam::PerspectiveCamera, u, v)
    Shoot a ray through the camera screen, u and v are the coordinates un the screen. (u,v)=(0,0) is the bottom left corner, (u,v)=(1,1) is the top right one.

    origin = Point(-cam.distance, 0.0, 0.0) --> set the origin on the projection of the given point with x coordinate=1.0
    direction = Vec(cam.distance, (1.0 - 2 * u) * cam.aspect_ratio, 2 * v - 1.0) --> the direction in OrthogonalCamera is always the x axis
    return cam.transformation*Ray(origin, direction) --> the camera transformationis applied and the fired Ray is returned
"""
function fire_single_ray(cam::PerspectiveCamera, u, v)
    
    origin = Point(-cam.distance, 0.0, 0.0)
    direction = Vec(cam.distance, (1.0 - 2 * u) * cam.aspect_ratio, 2 * v - 1.0)
    return cam.transformation(Ray(origin, direction))

end

"""
function aperture_deg(cam::PerspectiveCamera)
    Compute the aperture of the camera in degrees. The aperture is the angle of the field-of-view along the horizontal direction (Y axis).
"""
function aperture_deg(cam::PerspectiveCamera)
    return 2.0 * atan(cam.distance / cam.aspect_ratio) * 180.0 / π
end
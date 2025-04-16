#Camera struct

#Defining an abstarct type with two substructs
abstract type Camera
end

function fire_ray(cam::Camera, u, v)
    error("Metodo fire_ray non implementato per $(typeof(cam))")
end

#Defining substructs
#Orthogonal Camera
struct OrthogonalCamera <: Camera

    aspect_ratio::Float64
    transfromation::Transformation

    function OrthogonalCamera(aspect_ratio, transfromation::Transformation)
        new(aspect_ratio, transfromation)
    end

end

function fire_ray(cam::OrthogonalCamera, u, v)

    origin = Point(-1.0, (1.0 - 2 * u) * cam.aspect_ratio, 2 * v - 1)
    direction = Vec(1.0, 0.0, 0.0)
    return cam.transformation*Ray(origin=origin, dir=direction, tmin=1.0e-5)

end

#Perspective Camera
struct PerspectiveCamera <: Camera

    distance::Float64
    aspect_ratio::Float64
    transfromation::Transformation

    function PerspectiveCamera(distance, aspect_ratio, transfromation::Transformation)
        new(distance, aspect_ratio, transfromation)
    end

end

function fire_ray(cam::PerspectiveCamera, u, v)
    
    origin = Point(-cam.distance, 0.0, 0.0)
    direction = Vec(cam.distance, (1.0 - 2 * u) * cam.aspect_ratio, 2 * v - 1)
    return cam.transformation*Ray(origin=origin, dir=direction, tmin=1.0e-5)

end

function aperture_deg(cam::PerspectiveCamera)

    """Compute the aperture of the camera in degrees

    The aperture is the angle of the field-of-view along the horizontal direction (Y axis)"""
    return 2.0 * math.atan(cam.distance / cam.aspect_ratio) * 180.0 / 3.14159265359

end
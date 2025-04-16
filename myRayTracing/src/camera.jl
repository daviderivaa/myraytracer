#Camera struct

#Defining an abstarct type with two substructs
abstract type Camera
end

function fire_ray(cam::Camera, u, v)
end

#Defining substructs
#Orthogonal Camera
struct OrthogonalCamera <: Camera

    distance::Float64
    aspect_ratio::Float64
    transfromation::Transformation

    function OrthogonalCamera(distance, aspect_ratio, transfromation::Transformation)
        new(distance, aspect_ratio, transfromation)
    end

end

function fire_ray(cam::OrthogonalCamera, u, v)

    origin = Point(-1.0, (1.0 - 2 * u) * cam.aspect_ratio, 2 * v - 1)
    direction = VEC_X
    return Ray(origin=origin, dir=direction, tmin=1.0e-5).transform(cam.transformation)

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
    # codice specifico per PerspectiveCamera
end

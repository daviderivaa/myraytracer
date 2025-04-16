"""
Defining Ray struct and methods:

    - Origin::Point ((0,0,0)) --> 3D point where the ray starts from
    - dir::Vec ((0,0,0)) --> 3D direction of ray's propagation
    - tmin::float64 (0.00001) --> minimum distance of the rays
    - tmax::float64 (inf) --> maximum distance of the rays
    - depth::Int64 (0) --> number of times the ray is modified

    default values are (...)

""" 
struct Ray

    origin::Point
    dir::Vec
    tmin::Float64
    tmax::Float64
    depth::Int64

    function Ray(orig::Point = Point(), direc::Vec = Vec(), tminim::Float64 = 1e-5, tmaxim::Float64 = Inf, dep::Int64 = 0)
        new(orig, direc, tminim, tmaxim, dep)
    end

end

########################################################################################################################

#ray functions

"""
function at(ray, t)
    returns a 3D Point that gives the position of the ray after a step t
"""
function at(r::Ray, t::Float64)
    return r.origin + t*r.dir
end

"""
function is_close(ray1, ray2, epsilon=1e-5)
    checks if two rays have similar origins and directions
"""
function is_close(r_1::Ray, r_2::Ray, epsilon=1e-5)
    return (_are_xyz_close(r_1.origin, r_2.origin, epsilon) && _are_xyz_close(r_1.dir, r_2.dir, epsilon))
end

"""
function Base.:*(ray_in, transformation)
    returns a new ray appling a transformation to origin and direction of ray_in
"""
function Base.:*(transformation::Transformation, ray_in::Ray)
    return Ray((transformation*ray_in.origin), (transformation*ray_in.dir), ray_in.tmin, ray_in.tmax, ray_in.depth)
end
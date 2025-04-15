"""
Defining ray struct and methods:

    - Origin::Point ((0,0,0)) --> 3D point where the ray starts from
    - dir::Vec ((0,0,0)) --> 3D direction of ray's propagation
    - tmin::float64 (0.00001) --> minimum distance of the rays
    - tmax::float64 (inf) --> maximum distance of the rays
    - depth::Int64 (0) --> number of times the ray is modified

    default values are (...)

""" 

struct ray

    origin::Point
    dir::Vec
    tmin::Float64
    tmax::Float64
    depth::Int64

    function ray(orig::Point = Point(), direc::Vec = Vec(), tminim::Float64 = 1e-5, tmaxim::Float64 = Inf, dep::Int64 = 0)
        new(orig, direc, tminim, tmaxim, dep)
    end

end

########################################################################################################################

#ray functions
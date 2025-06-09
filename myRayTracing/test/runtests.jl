using myRayTracing
using Test
using LinearAlgebra
using Colors

@testset "Check _read_float" begin
    
    @test _read_float(IOBuffer([0xDB,0x0F,0x49,0x40]), -1.0)≈3.14159 #Little-endian 
    @test _read_float(IOBuffer([0x40,0x49,0x0F,0xDb]), 1.0)≈3.14159 #big-endian

end

@testset "Check _parse_endianness" begin

    @test _parse_endianness("1")≈1
    @test _parse_endianness("-1")≈-1
    
    @test_throws InvalidPfmFileFormat _parse_endianness("0")
    @test_throws InvalidPfmFileFormat _parse_endianness("pippo")
    @test_throws InvalidPfmFileFormat _parse_endianness("0.0")
    @test_throws InvalidPfmFileFormat _parse_endianness("nan")

end

@testset "Check _read_line" begin
    
    @test _read_line(IOBuffer([0x70, 0x69, 0x70, 0x70, 0x6F, 0x0A]))=="pippo"
    @test _read_line(IOBuffer([0x70, 0x69, 0x70, 0x70, 0x6F]))=="pippo"

    @test_throws InvalidPfmFileFormat _read_line(IOBuffer([0x0A]))

end

@testset "Check Color_and_HdrImage functions" begin

    mat = [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.0, 0.5, 0.5, 0.5, 0.0, 0.0, 0.0]
    
    image = HdrImage(mat, 3, 2)

    @test image.pixels[2, 1] == RGB(1.0, 0.0, 0.0)
    @test image.pixels[2, 2] == RGB(0.0, 1.0, 0.0)
    @test image.pixels[2, 3] == RGB(0.0, 0.0, 1.0)
    @test image.pixels[1, 1] == RGB(1.0, 1.0, 0.0)
    @test image.pixels[1, 2] == RGB(0.5, 0.5, 0.5)
    @test image.pixels[1, 3] == RGB(0.0, 0.0, 0.0)

end

@testset "Check geometry functions" begin

    a = Vec(0.8, -0.5, 1.4)
    b = Vec(-1.6, 0.5, -0.7)
    c = Vec(3.0, 4.0, 0.0)
    d = Vec2d(1.5, 0.7)
    e = Vec2d(-3.4, 5.1)
    A = Point(0.8, -0.5, 1.4)
    B = Point(-1.6, 0.5, -0.7)
    na = Normal(0.8, -0.5, 1.4)
    nb = Normal(-1.6, 0.5, -0.7)
    
    lambda = 2.0
    
    @test_throws Type_error print_element(lambda)
    @test is_close(a+b, Vec(-0.8, 0.0, 0.7))
    @test is_close(a-b, Vec(2.4, -1.0, 2.1))
    @test is_close(d+e, Vec2d(-1.9, 5.8))
    @test is_close(d-e, Vec2d(4.9, -4.4))
    @test typeof(A+a)==Point
    @test typeof(A-a)==Point
    @test typeof(A-B)==Vec
    @test is_close(A+a, Point(1.6, -1.0, 2.8))
    @test is_close(A+a, a+A)
    @test is_close(A-a, Point(0.0, 0.0, 0.0))
    @test is_close(A-B, Vec(2.4, -1.0, 2.1))
    @test is_close(lambda * a, Vec(1.6, -1.0, 2.8))
    @test is_close(lambda * a, a * lambda)
    @test is_close(neg(na), Normal(-0.8, 0.5, -1.4))
    @test abs(a*b + 2.51) <= 1e-6 
    @test abs(squared_norm(a) - 2.85) <= 1e-6
    @test abs(norm(a) - 1.6881943016) <= 1e-6
    @test is_close(normalize(c), Vec(0.6, 0.8, 0.0))
    @test is_close(normalize(Vec_to_Normal(c)), Normal(0.6, 0.8, 0.0))
    @test is_close(cross(a,b), Vec(-0.35,-1.68,-0.4))
    @test typeof(Vec_to_Point(a))==Point
    @test typeof(Point_to_Vec(A))==Vec

end

@testset "Check Transformation functions" begin

    o = Point(0.0, 0.0, 0.0)
    p = Point(1.0, 2.0, 3.0)
    v = Vec(1.0, 2.0, 3.0)
    n = Normal(0.0, 0.0, 1.0)
    u = Vec(9.0, 8.0, 7.0)
    t = traslation(u)
    rx = rotation("x", pi/2)
    ry = rotation("y", pi/2)
    rz = rotation("z", pi/2)
    s = scaling(2.0)
    s2 = scaling(2.0, 3.0, 4.0)
    inv_t = inverse(t)
    inv_rx = inverse(rx)
    inv_s2 = inverse(s2)

    @test is_consistent(t)
    @test is_consistent(ry)
    @test is_consistent(s2)
    @test is_close(t(p), Point(10.0, 10.0, 10.0))
    @test is_close(t(v), v)
    @test is_close(rx(p), Point(1.0, -3.0, 2.0))
    @test is_close(ry(p), Point(3.0, 2.0, -1.0))
    @test is_close(rz(p), Point(-2.0, 1.0, 3.0))
    @test is_close(rx(v), Vec(1.0, -3.0, 2.0))
    @test is_close(ry(v), Vec(3.0, 2.0, -1.0))
    @test is_close(rz(v), Vec(-2.0, 1.0, 3.0))
    @test is_close(s(p), Point(2.0, 4.0, 6.0))
    @test is_close(s(v), Vec(2.0, 4.0, 6.0))
    @test is_close(s2(p), Point(2.0, 6.0, 12.0))
    @test is_close(s2(v), Vec(2.0, 6.0, 12.0))
    @test is_close(t(o), Vec_to_Point(u))
    @test is_close(t(rz(o)), Vec_to_Point(u))
    @test is_close(rz(t(o)), Point(-8.0, 9.0, 7.0))
    @test is_consistent(inv_t)
    @test is_consistent(inv_rx)
    @test is_consistent(inv_s2)
    @test is_close(inv_t(t(p)), p)
    @test is_close(inv_rx(rx(p)), p)
    @test is_close(inv_s2(s2(p)), p)

end

@testset "Check ray methods" begin

    p = Point(1.0, 2.0, 3.0)
    v = Vec(1.0, 2.0, 3.0)
    r = Ray(p,v)
    r_2 = Ray(Point(3.0, 6.0, 9.0),v)

    rz = rotation("z", pi/2)
    transformed_ray = Ray(Point(-2.0, 1.0, 3.0),Vec(-2.0, 1.0, 3.0))

    @test is_close(at(r,2.0), Point(3.0, 6.0, 9.0))
    @test is_close(Ray(at(r, 2.0),v), r_2)
    @test is_close(rz(r), transformed_ray)

end

@testset "Check camera methods" begin

    vec = Vec(0.0, 0.0, 0.0)
    t = traslation(vec)
    OC = OrthogonalCamera((16.0/9.0), t)
    PC = PerspectiveCamera(1.0, (16.0/9.0), t)
    OCorigin = Point(-1.0, (16.0/9.0), -1.0)
    OCdirection = Vec(1.0, 0.0, 0.0)
    OCray = Ray(OCorigin, OCdirection)
    PCorigin = Point(-1.0, 0.0, 0.0)
    PCdirection = Vec(1.0, (16.0/9.0), -1.0)
    PCray = Ray(PCorigin, PCdirection)

    @test is_close(fire_single_ray(OC, 0.0, 0.0), OCray)
    @test is_close(fire_single_ray(PC, 0.0, 0.0), PCray)
    @test aperture_deg(PC) == 2.0 * atan(9.0/16.0) * 180.0 / π

end

@testset "Check ImageTracer methods" begin
    
    vec = Vec(0.0, 0.0, 0.0)
    t = traslation(vec)
    OC = OrthogonalCamera((16.0/9.0), t)
    PC = PerspectiveCamera(1.0, (16.0/9.0), t)
    image = HdrImage(2,3)

    OItracer = ImageTracer(image, OC)
    PItracer = ImageTracer(image, PC)

    ray1 = fire_ray(PItracer, 0, 0, 2.5, 1.5)
    ray2 = fire_ray(PItracer, 2, 1)
    @test is_close(ray1, ray2)

    function func(ray::Ray)
        return RGB(1.0, 2.0, 3.0)
    end

    fire_all_rays!(PItracer, func)
    for row in 1:PItracer.img.height
        for col in 1:PItracer.img.width
            @test PItracer.img.pixels[row, col] ≈ RGB(1.0, 2.0, 3.0)
        end
    end

    fire_all_rays!(OItracer, func)
    for row in 1:OItracer.img.height
        for col in 1:OItracer.img.width
            @test OItracer.img.pixels[row, col] ≈ RGB(1.0, 2.0, 3.0)
        end
    end

end

@testset "Check HitRecord methods" begin

    id = Matrix{Float64}(I(4))
    null_transform = Transformation(id)
    pl = Plane(null_transform)
    
    HR1 = HitRecord(Point(0.0, 1.0, 2.0), Normal(1.0, 1.0, 1.0), Vec2d(0.0, 0.0), 3.0, Ray(Point(0.0, 0.0, 0.0), Vec(1.0, 0.0, 0.0)), pl)
    HR2 = HitRecord(Point(0.0, 1.0, 2.0), Normal(1.0, 1.0, 1.0), Vec2d(0.0, 0.0), 3.0, Ray(Point(0.0, 0.0, 0.0), Vec(1.0, 0.0, 0.0)), pl)

    @test is_close(HR1, HR2)

end

@testset "Check sphere methods" begin

    id = Matrix{Float64}(I(4))
    null_transform = Transformation(id)
    sph_1 = Sphere(null_transform)

    ray_1 = Ray(Point(0.0, 0.0, 2.0), Vec(0.0, 0.0, -1.0))
    ray_2 = Ray(Point(3.0, 0.0, 0.0), Vec(-1.0, 0.0, 0.0))
    ray_3 = Ray(Point(0.0, 0.0, 0.0), Vec(1.0, 0.0, 0.0))
    p_1 = Point(0.0, 0.0, 1.0)
    p_2 = Point(1.0, 0.0, 0.0)
    n_1 = Normal(0.0, 0.0, 1.0)
    n_2 = Normal(1.0, 0.0, 0.0)
    n_3 = Normal(-1.0, 0.0, 0.0)

    @test quick_ray_intersection(sph_1, ray_1) == true
    @test quick_ray_intersection(sph_1, ray_2) == true
    @test quick_ray_intersection(sph_1, ray_3) == true

    hr_1 = ray_intersection(sph_1, ray_1)
    hr_2 = ray_intersection(sph_1, ray_2) 
    hr_3 = ray_intersection(sph_1, ray_3)

    HRtest_1 = HitRecord(p_1, n_1, Vec2d(0.0, 0.0), 1.0, ray_1, sph_1)
    HRtest_2 = HitRecord(p_2, n_2, Vec2d(0.0, 0.5), 2.0, ray_2, sph_1)
    HRtest_3 = HitRecord(p_2, n_3, Vec2d(0.0, 0.5), 1.0, ray_3, sph_1)

    @test is_close(hr_1, HRtest_1)
    @test is_close(hr_2, HRtest_2)
    @test is_close(hr_3, HRtest_3)

    v = Vec(10.0, 0.0, 0.0)
    tr = traslation(v)
    sph_2 = Sphere(tr)

    ray_4 = Ray(Point(10.0, 0.0, 2.0), Vec(0.0, 0.0, -1.0))
    ray_5 = Ray(Point(13.0, 0.0, 0.0), Vec(-1.0, 0.0, 0.0))
    p_4 = Point(10.0, 0.0, 1.0)
    p_5 = Point(11.0, 0.0, 0.0)

    @test quick_ray_intersection(sph_2, ray_4) == true
    @test quick_ray_intersection(sph_2, ray_5) == true

    hr_4 = ray_intersection(sph_2, ray_4)
    hr_5 = ray_intersection(sph_2, ray_5)

    HRtest_4 = HitRecord(p_4, n_1, Vec2d(0.0, 0.0), 1.0, ray_4, sph_2)
    HRtest_5 = HitRecord(p_5, n_2, Vec2d(0.0, 0.5), 2.0, ray_5, sph_2)

    @test is_close(hr_4, HRtest_4)
    @test is_close(hr_5, HRtest_5)

    ray_6 = Ray(Point(0.0, 0.0, 2.0), Vec(0.0, 0.0, 1.0))
    ray_7 = Ray(Point(-15.0, 0.0, 0.0), Vec(0.0, 0.0, -1.0))
    ray_8 = Ray(Point(5.0, 0.0, 0.0), Vec(-1.0, 0.0, 0.0))

    @test quick_ray_intersection(sph_1, ray_6) == false
    @test quick_ray_intersection(sph_1, ray_7) == false
    @test quick_ray_intersection(sph_2, ray_8) == false

    hr_6 = ray_intersection(sph_1, ray_6)
    hr_7 = ray_intersection(sph_1, ray_7)
    hr_8 = ray_intersection(sph_2, ray_8)

    @test hr_6 === nothing
    @test hr_7 === nothing
    @test hr_8 === nothing

end

@testset "Check plane methods" begin

    id = Matrix{Float64}(I(4))
    null_transform = Transformation(id)
    pl_1 = Plane(null_transform)

    v = Vec(10.0, 7.0, 5.0)
    trasl = traslation(v)
    pl_2 = Plane(trasl)

    rot = rotation("x", π/4)
    pl_3 = Plane(rot)

    ray_1 = Ray(Point(1.0, 2.0, 10.0), Vec(0.0, 0.0, -1.0))
    ray_2 = Ray(Point(0.0, 0.0, -3.0), Vec(1.0, 1.0, 1.0))
    ray_3 = Ray(Point(0.0, 0.0, 1.0), Vec(1.0, 0.0, 0.0))
    ray_4 = Ray(Point(0.0, 0.0, 1.0), Vec(0.0, 1.0, 0.0))
    ray_5 = Ray(Point(0.0, 0.0, 2.0), Vec(0.0, 0.0, 1.0))

    @test quick_ray_intersection(pl_1, ray_1) == true
    @test quick_ray_intersection(pl_1, ray_2) == true
    @test quick_ray_intersection(pl_1, ray_3) == false
    @test quick_ray_intersection(pl_2, ray_1) == true
    @test quick_ray_intersection(pl_2, ray_3) == false
    @test quick_ray_intersection(pl_3, ray_1) == true
    @test quick_ray_intersection(pl_3, ray_3) == false
    @test quick_ray_intersection(pl_3, ray_4) == true
    @test quick_ray_intersection(pl_1, ray_5) == false
    @test quick_ray_intersection(pl_2, ray_5) == true

    hr_11 = ray_intersection(pl_1, ray_1)
    hr_12 = ray_intersection(pl_1, ray_2) 
    hr_21 = ray_intersection(pl_2, ray_1)
    hr_34 = ray_intersection(pl_3, ray_4)

    HRtest_11 = HitRecord(Point(1.0, 2.0, 0.0), Normal(0.0, 0.0, 1.0), Vec2d(0.0, 0.0), 10.0, ray_1, pl_1)
    HRtest_12 = HitRecord(Point(3.0, 3.0, 0.0), Normal(0.0, 0.0, -1.0), Vec2d(0.0, 0.0), 3.0, ray_2, pl_1)
    HRtest_21 = HitRecord(Point(1.0, 2.0, 5.0), Normal(0.0, 0.0, 1.0), Vec2d(0.0, 0.0), 5.0, ray_1, pl_2)
    HRtest_34 = HitRecord(Point(0.0, 1.0, 1.0), Normal(0.0, -(√2)/2, (√2)/2), Vec2d(0.0, (√2)-1), 1.0, ray_4, pl_3)

    @test is_close(hr_11, HRtest_11)
    @test is_close(hr_12, HRtest_12)
    @test is_close(hr_21, HRtest_21)
    @test is_close(hr_34, HRtest_34)

end

@testset "Check box methods" begin
    box1 = Box(1.0, 2.0, 3.0)
    box2 = Box(1.0, 2.0, 3.0, traslation(Vec(0.0,0.0,10.0)))
    box3 = Box(1.0, 2.0, 3.0, rotation("z", π/2))

    ray_1 = Ray(Point(-2.0, -1.0, -3.0), Vec(3.0, 1.0, 5.0))
    ray_2 = Ray(Point(-1.0, 0.5, 2.0), Vec(1.0, 0.0, 0.0))
    ray_3 = Ray(Point(-5.0, 0.5, 1.0), Vec(1.0, 0.0, 0.0))
    ray_4 = Ray(Point(0.5, 4.0, 1.5), Vec(0.0, -1.0, 0.0))
    ray_5 = Ray(Point(0.5, 1.0, 5.0), Vec(0.0, 0.0, 1.0))
    ray_6 = Ray(Point(0.5, 1.0, 5.0), Vec(0.0, 0.0, -1.0))

    @test quick_ray_intersection(box1, ray_1) == false
    @test ray_intersection(box1, ray_1) === nothing
    @test quick_ray_intersection(box2, ray_1) == false
    @test ray_intersection(box2, ray_1) === nothing
    @test quick_ray_intersection(box3, ray_1) == false
    @test ray_intersection(box3, ray_1) === nothing

    @test quick_ray_intersection(box1, ray_2) == true
    hr12 = ray_intersection(box1, ray_2)
    @test abs(hr12.t - 1.0) < 1e-6
    @test is_close(hr12.world_point, Point(0.0, 0.5, 2.0))
    @test quick_ray_intersection(box2, ray_2) == false
    @test ray_intersection(box2, ray_2) === nothing
    @test quick_ray_intersection(box3, ray_2) == true
    hr32 = ray_intersection(box3, ray_2)
    @test abs(hr32.t - 1.0) < 1e-6
    @test is_close(hr32.normal, Normal(-1.0, 0.0, 0.0))

    @test quick_ray_intersection(box1, ray_3) == true
    hr13 = ray_intersection(box1, ray_3)
    @test abs(hr13.t - 5.0) < 1e-6
    @test quick_ray_intersection(box2, ray_3) == false
    @test ray_intersection(box2, ray_3) === nothing
    @test quick_ray_intersection(box3, ray_3) == true
    hr33 = ray_intersection(box3, ray_3)
    @test abs(hr33.t - 3.0) < 1e-6

    @test quick_ray_intersection(box1, ray_4) == true
    @test ray_intersection(box1, ray_4) !== nothing
    @test quick_ray_intersection(box2, ray_4) == false
    @test ray_intersection(box2, ray_4) === nothing
    @test quick_ray_intersection(box3, ray_4) == false
    @test ray_intersection(box3, ray_4) === nothing

    @test quick_ray_intersection(box1, ray_5) == false
    @test ray_intersection(box1, ray_5) === nothing
    @test quick_ray_intersection(box2, ray_5) == true
    hr25 = ray_intersection(box2, ray_5)
    @test abs(hr25.t - 5.0) < 1e-6
    @test quick_ray_intersection(box3, ray_5) == false
    @test ray_intersection(box3, ray_5) === nothing

    @test quick_ray_intersection(box1, ray_6) == true
    hr16 = ray_intersection(box1, ray_6)
    @test abs(hr16.t - 2.0) < 1e-6
    @test quick_ray_intersection(box2, ray_6) == false
    @test ray_intersection(box2, ray_6) === nothing
    @test quick_ray_intersection(box3, ray_6) == false
    @test ray_intersection(box3, ray_6) === nothing
end

@testset "Check cylinder methods" begin
    cyl1 = Cylinder(1.0,1.0)
    cyl2 = Cylinder(1.0,2.0)
    cyl3 = Cylinder(1.0,2.0, traslation(Vec(-1.0,-1.0))(rotation("x", π/2)))

    ray1 = Ray(Point(-2.0,0.0,0.5), Vec(1.0,0.0,0.0))
    ray2 = Ray(Point(-2.0,0.0,1.5), Vec(1.0,0.0,0.0))
    ray3 = Ray(Point(-3.0,2.0,-7.0), Vec(1.0,-2.0,3.0))
    ray4 = Ray(Point(0.0,0.0,1.5), Vec(0.0,0.0,-1.0))

    @test quick_ray_intersection(cyl1, ray1) == true
    @test ray_intersection(cyl1, ray1) !== nothing
    @test quick_ray_intersection(cyl2, ray1) == true
    @test ray_intersection(cyl2, ray1) !== nothing
    @test quick_ray_intersection(cyl3, ray1) == false
    @test ray_intersection(cyl3, ray1) === nothing

    @test quick_ray_intersection(cyl1, ray2) == false
    @test ray_intersection(cyl1, ray2) === nothing
    @test quick_ray_intersection(cyl2, ray2) == true
    @test ray_intersection(cyl2, ray2) !== nothing
    @test quick_ray_intersection(cyl3, ray2) == false
    @test ray_intersection(cyl3, ray2) === nothing

    @test quick_ray_intersection(cyl1, ray3) == false
    @test ray_intersection(cyl1, ray3) === nothing
    @test quick_ray_intersection(cyl2, ray3) == false
    @test ray_intersection(cyl2, ray3) === nothing
    @test quick_ray_intersection(cyl3, ray3) == true
    @test ray_intersection(cyl3, ray3) !== nothing

    @test quick_ray_intersection(cyl1, ray4) == true
    hr14 = ray_intersection(cyl1, ray4)
    @test abs(hr14.t - 0.5) < 1e-6
    @test is_close(hr14.normal, Normal(0.0, 0.0, 1.0))
    @test quick_ray_intersection(cyl2, ray4) == true
    hr24 = ray_intersection(cyl2, ray4)
    @test abs(hr24.t - 1.5) < 1e-6
    @test is_close(hr24.normal, Normal(0.0, 0.0, 1.0))
    @test quick_ray_intersection(cyl3, ray4) == false
    @test ray_intersection(cyl3, ray4) === nothing
end

@testset "Check cone methods" begin
    con1 = Cone(1.0, 2.0)
    con2 = Cone(1.0, 2.0, traslation(Vec(0.0, 0.0, 2.0))(rotation("y", π)))
    con3 = Cone(2.0, 3.0, rotation("x", π/2))

    ray1 = Ray(Point(0.0, -1.0, 1.0), Vec(0.0, 1.0, 0.0))
    ray2 = Ray(Point(-2.0, 0.5, 1.9), Vec(1.0, 0.0, 0.0))
    ray3 = Ray(Point(0.0, 0.1, 3.0), Vec(0.0, 0.0, -1.0))
    ray4 = Ray(Point(4.0, 5.0, -6.0), Vec(0.0, 0.0, 1.0))

    @test quick_ray_intersection(con1, ray1) == true
    @test ray_intersection(con1, ray1) !== nothing
    @test quick_ray_intersection(con2, ray1) == true
    @test ray_intersection(con2, ray1) !== nothing
    @test quick_ray_intersection(con3, ray1) == true
    @test ray_intersection(con3, ray1) !== nothing

    @test quick_ray_intersection(con1, ray2) == false
    @test ray_intersection(con1, ray2) === nothing
    @test quick_ray_intersection(con2, ray2) == true
    @test ray_intersection(con2, ray2) !== nothing
    @test quick_ray_intersection(con3, ray2) == false
    @test ray_intersection(con3, ray2) === nothing

    @test quick_ray_intersection(con1, ray3) == true
    @test ray_intersection(con1, ray3) !== nothing
    @test quick_ray_intersection(con2, ray3) == true
    @test ray_intersection(con2, ray3) !== nothing
    @test quick_ray_intersection(con3, ray3) == false
    @test ray_intersection(con3, ray3) === nothing

    cone = Cone(2.0, 2.0, rotation("z", π/2))
    ray = Ray(Point(0.0, 3.0, 3.0), Vec(0.0, -1/√2, -1/√2))
    hr = ray_intersection(cone, ray)
    hr_test = HitRecord(Point(0.0, 1.0, 1.0),
                        Normal(0.0, 1/√2, 1/√2),
                        Vec2d(0.5, 0.5),
                        2√2,
                        ray,
                        cone)
    @test is_close(hr, hr_test)
end

@testset "Check csg (union) methods" begin
    box = Box(2.0, 2.0, 2.0)
    sphere = Sphere(traslation(Vec(1.0, 0.0, 1.0)))
    cylinder = Cylinder(0.5, 4.0)
    cone = Cone(1.0, 1.0001, traslation(Vec(0.0001, 1.0, 1.0))(rotation("y", -π/2)))
    u1 = union_shape(box, cone)
    u2 = union_shape(sphere, cylinder, traslation(Vec(1.0, 1.0, 0.0)))
    final = union_shape(u1, u2)

    ray1 = Ray(Point(1.0, 3.0, 3.0), Vec(0.0, -1.0, 0.0))
    ray2 = Ray(Point(1.0, 1.0, 1.0), Vec(0.0, 1.0, 0.0))
    ray3 = Ray(Point(-0.5, 1.0, 1.0), Vec(1.0, 0.0, 0.0))
    ray4 = Ray(Point(-0.5, -1.0, 1.0), Vec(0.0, 1.0, 0.0))
    ray5 = Ray(Point(-3.0, -1.0, -2.0), Vec(1.0, 2.0, 3.0))

    @test quick_ray_intersection(final, ray1) == true
    hr1 = ray_intersection(final, ray1)
    @test abs(hr1.t - 1.5) < 1e-6
    @test hr1.s == cylinder
    

    @test quick_ray_intersection(final, ray2) == true
    hr2 = ray_intersection(final, ray2)
    @test abs(hr2.t - 1.0) < 1e-6
    @test hr2.s == box

    @test quick_ray_intersection(final, ray3) == true
    hr3 = ray_intersection(final, ray3)
    @test abs(hr3.t - 3.5) < 1e-6
    @test hr3.s == sphere

    @test quick_ray_intersection(final, ray4) == true
    hr4 = ray_intersection(final, ray4)
    @test abs(hr4.t - 1.5) < 1e-4
    @test hr4.s == cone

    @test quick_ray_intersection(final, ray5) == false
end

@testset "Check csg (intersection) methods" begin
    box = Box(3.0, 3.0, 3.0)
    sphere = Sphere(traslation(Vec(0.0, 3.0, 0.0))(scaling(2.0)))
    final = intersec_shape(box, sphere, traslation(Vec(4.0, -5.0, 1.0))(rotation("z", -π/2)))

    ray1 = Ray(Point(2.0, -6.0, 2.0), Vec(1.0, 0.0, 0.0))
    ray2 = Ray(Point(2.5, -1.0, 1.0), Vec(0.0, 1.0, 0.0))
    ray3 = final.T(ray2)
    ray4 = Ray(Point(6.0, 1.0, 1.5), Vec(0.0, -1.0, 0.0))
    ray5 = Ray(Point(6.5, -5.5, 10.0), Vec(0.0, 0.0, -1.0))

    @test quick_ray_intersection(final, ray1) == true
    hr1 = ray_intersection(final, ray1)
    @test hr1.s == sphere
    
    @test quick_ray_intersection(box, ray2) == true
    @test quick_ray_intersection(sphere, ray2) == false
    @test quick_ray_intersection(final, ray3) == false

    @test quick_ray_intersection(final, ray4) == true
    hr4 = ray_intersection(final, ray4)
    @test abs(hr4.t - 6.0) < 1e-6
    @test hr4.s == box

    @test quick_ray_intersection(final, ray5) == true
    hr5 = ray_intersection(final, ray5)
    @test hr5.s == sphere
end

@testset "Check csg (difference) methods" begin
    bigbox = Box(4.0, 4.0, 4.0)
    smallbox = Box(2.0, 2.1, 2.0, traslation(Vec(1.0, -0.1, 0.0)))
    sphere = Sphere(scaling(2.0))
    cylinder = Cylinder(0.5, 6.0, traslation(Vec(-1.0, 3.0, 2.0))(rotation("y", π/2)))
    d1 = diff_shape(bigbox, smallbox)
    d2 = diff_shape(d1, sphere)
    final = diff_shape(d2, cylinder)

    ray1 = Ray(Point(-2.0, 1.0, 1.0), Vec(1.0, 0.0, 0.0))
    ray2 = Ray(Point(-3.0, 3.0, 2.0), Vec(1.0, 0.0, 0.0))
    ray3 = Ray(Point(2.0, -3.0, 1.0), Vec(0.0, 1.0, 0.0))
    ray4 = Ray(Point(2.0, 1.0, 5.0), Vec(0.0, 0.0, -1.0))
    ray5 = Ray(Point(2.0, 1.0, -5.0), Vec(0.0, 0.0, 1.0))
    ray6 = Ray(Point(2.0, 5.0, 3.0), Vec(1.0, -1.0, 2.0))

    @test quick_ray_intersection(d1, ray1) == true
    hr11 = ray_intersection(d1, ray1)
    @test abs(hr11.t - 2.0) < 1e-6
    @test hr11.s == bigbox
    @test quick_ray_intersection(final, ray1) == true
    hr12 = ray_intersection(final, ray1)
    @test abs(hr12.t - 5.0) < 1e-6
    @test hr12.s == smallbox

    @test quick_ray_intersection(d2, ray2) == true
    @test quick_ray_intersection(cylinder, ray2) == true
    @test quick_ray_intersection(final, ray2) == false
    @test ray_intersection(final, ray2) === nothing

    @test quick_ray_intersection(bigbox, ray3) == true
    @test quick_ray_intersection(final, ray3) == true
    hr3 = ray_intersection(final, ray3)
    @test abs(hr3.t - 5.0) < 1e-6
    @test hr3.s == smallbox

    @test quick_ray_intersection(final, ray4) == true
    hr4 = ray_intersection(final, ray4)
    @test abs(hr4.t - 1.0) < 1e-6
    @test hr4.s == bigbox

    @test quick_ray_intersection(final, ray5) == true
    hr5 = ray_intersection(final, ray5)
    @test abs(hr5.t - 7.0) < 1e-6
    @test hr5.s == smallbox

    @test quick_ray_intersection(final, ray6) == false
    @test ray_intersection(final, ray6) === nothing
end

@testset "Check world methods" begin
    
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

    r1 = Ray(Point(0.0, 0.0, 0.0), Vec(0.0, 0.0, -1.0))
    r2 = Ray(Point(0.0, 0.0, 0.0), Vec(1.0, 0.0, 0.0))

    inv_r = inverse(s1.T)(r1)
    o_vec = Point_to_Vec(inv_r.origin)

    a = squared_norm(inv_r.dir)
    b = o_vec * inv_r.dir #tecnically is b/2, but we will use delta/4
    c = squared_norm(o_vec) - 1
    delta = b*b - a*c #it's delta/4
 
    sqrt_delta = √(delta)

    t_1 = ( -b - sqrt_delta ) / a
    t_2 = ( -b + sqrt_delta ) / a

    if (t_1 > inv_r.tmin) && (t_1 < inv_r.tmax)
        t_hit = t_1
    elseif (t_2 > inv_r.tmin) && (t_2 < inv_r.tmax)
        t_hit = t_2
    else
        return nothing
    end

    point_hit = at(inv_r, t_hit)

    #p = Point(0.0, 0.0, -0.4)
    u = atan(point_hit.y, point_hit.x) / (2π)
    v = acos(point_hit.z) / π
    u = u >= 0.0 ? u : u + 1.0

    @test is_close(ray_intersection(w, r1), HitRecord(Point(0.0, 0.0, -0.4), Normal(0.0, 0.0, 1.0), Vec2d(u,v), t_hit, r1, s1))
    @test ray_intersection(w, r2) === nothing

    visible_point = Point(1.0, -2.0, 2.0)
    invisible_point = Point(5.0, -0.5, 0.5)
    observer_point = Point(0.0, -0.5, 0.5)

    @test is_point_visible(w, visible_point, observer_point)
    @test !is_point_visible(w, invisible_point, observer_point)

end

@testset "Check Pigment methods" begin
    
    color = RGB(1.0, 2.0, 3.0)
    pigment = UniformPigment(color)

    @test get_color(pigment, Vec2d(0.0, 0.0)) == color
    @test get_color(pigment, Vec2d(1.0, 0.0)) == color
    @test get_color(pigment, Vec2d(0.0, 1.0)) == color
    @test get_color(pigment, Vec2d(1.0, 1.0)) == color

    image = HdrImage(2, 2)
    image.pixels[1, 1] = RGB(1.0, 2.0, 3.0)
    image.pixels[1, 2] = RGB(2.0, 3.0, 1.0)
    image.pixels[2, 1] = RGB(2.0, 1.0, 3.0)
    image.pixels[2, 2] = RGB(3.0, 2.0, 1.0)
    
    pigment = ImagePigment(image)
    @test get_color(pigment, Vec2d(0.0, 0.0)) == RGB(1.0, 2.0, 3.0)
    @test get_color(pigment, Vec2d(1.0, 0.0)) == RGB(2.0, 3.0, 1.0)
    @test get_color(pigment, Vec2d(0.0, 1.0)) == RGB(2.0, 1.0, 3.0)
    @test get_color(pigment, Vec2d(1.0, 1.0)) == RGB(3.0, 2.0, 1.0)

    color1 = RGB(1.0, 2.0, 3.0)
    color2 = RGB(10.0, 20.0, 30.0)

    pigment = CheckeredPigment(color1, color2, 2)

    @test get_color(pigment, Vec2d(0.25, 0.25)) == color1
    @test get_color(pigment, Vec2d(0.75, 0.25)) == color2
    @test get_color(pigment, Vec2d(0.25, 0.75)) == color2
    @test get_color(pigment, Vec2d(0.75, 0.75)) == color1

end

@testset "Check PCG methods" begin

    pcg = new_PCG()

    @test pcg.state == 1753877967969059832
    @test pcg.inc == 109

    val = random!(pcg)
    @test val == 2707161783

    val = random!(pcg)
    @test val == 2068313097

    val = random!(pcg)
    @test val == 3122475824

    val = random!(pcg)
    @test val == 2211639955

    val = random!(pcg)
    @test val == 3215226955

    val = random!(pcg)
    @test val == 3421331566

end

@testset "Check ONB creation" begin
    pcg = new_PCG()

    for i in 0:100

        normale = normalize(Normal(norm_random!(pcg), norm_random!(pcg), norm_random!(pcg)))
        vec = normalize(Vec(norm_random!(pcg), norm_random!(pcg), norm_random!(pcg)))

        e1_n, e2_n, e3_n = create_onb_from_z(normale)
        e1_v, e2_v, e3_v = create_onb_from_z(vec)

        @test is_close(e3_n, Norm_to_Vec(normale))
        @test is_close(e3_v, vec, 1e-05)

        @test squared_norm(e1_n) ≈ 1.0
        @test squared_norm(e2_n) ≈ 1.0
        @test squared_norm(e3_n) ≈ 1.0
        @test squared_norm(e1_v) ≈ 1.0
        @test squared_norm(e2_v) ≈ 1.0
        @test squared_norm(e3_v) ≈ 1.0

        @test e1_n * e2_n <= 1e-10
        @test e2_n * e3_n <= 1e-10
        @test e1_n * e3_n <= 1e-10
        @test e1_v * e2_v <= 1e-10
        @test e2_v * e3_v <= 1e-10
        @test e1_v * e3_v <= 1e-10

    end
end

@testset "Furnace test" begin

    pcg = new_PCG()

    ## FIX FURNACE TEST

    for i in 1:2000

        emitted_radiance = norm_random!(pcg)
        reflectance = norm_random!(pcg)*0.8

        w = World()
        furnace_material = Material(DiffuseBRDF(UniformPigment(RGB(1.0 , 1.0 , 1.0) * reflectance)), UniformPigment(RGB(1.0 , 1.0 , 1.0) * emitted_radiance))

        add_shape!(w, Sphere(Transformation(Matrix{Float64}(I(4))), furnace_material))

        path_tracer = PathTracer(w, RGB(0.0, 0.0, 0.0), pcg, 1, 100, 101)
        ray = Ray(Point(0.0, 0.0, 0.0), Vec(1.0, 0.0, 0.0))
        color = path_tracer(ray)

        expected = emitted_radiance / (1.0 - reflectance)

        @test isapprox(expected, color.r; rtol=0, atol=1e-3)
        @test isapprox(expected, color.g; rtol=0, atol=1e-3)
        @test isapprox(expected, color.b; rtol=0, atol=1e-3)
    end
end
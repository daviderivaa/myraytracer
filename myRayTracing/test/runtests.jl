using myRayTracing
using Test

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
    @test is_close(normalize(c), Normal(0.6, 0.8, 0.0))
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

    fire_all_rays!(PItracer, RGB(1.0, 2.0, 3.0))
    for row in 1:PItracer.img.height
        for col in 1:PItracer.img.width
            @test PItracer.img.pixels[row, col] ≈ RGB(1.0, 2.0, 3.0)
        end
    end

    fire_all_rays!(OItracer, RGB(1.0, 2.0, 3.0))
    for row in 1:OItracer.img.height
        for col in 1:OItracer.img.width
            @test OItracer.img.pixels[row, col] ≈ RGB(1.0, 2.0, 3.0)
        end
    end

end

@testset "Check HitRecord methods" begin
    
    HR1 = HitRecord(Point(0.0, 1.0, 2.0), Normal(1.0, 1.0, 1.0), Vec2d(0.0, 0.0), 3.0, Ray(Point(0.0, 0.0, 0.0), Vec(1.0, 0.0, 0.0)))
    HR2 = HitRecord(Point(0.0, 1.0, 2.0), Normal(1.0, 1.0, 1.0), Vec2d(0.0, 0.0), 3.0, Ray(Point(0.0, 0.0, 0.0), Vec(1.0, 0.0, 0.0)))

    @test is_close(HR1, HR2)

end
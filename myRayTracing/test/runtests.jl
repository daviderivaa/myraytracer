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
    A = Point(0.8, -0.5, 1.4)
    B = Point(-1.6, 0.5, -0.7)
    na = Normal(0.8, -0.5, 1.4)
    nb = Normal(-1.6, 0.5, -0.7)
    
    lambda = 2.0
    
    @test_throws Type_error print_element(lambda)
    @test _are_xyz_close(a+b, Vec(-0.8, 0.0, 0.7))
    @test _are_xyz_close(a-b, Vec(2.4, -1.0, 2.1))
    @test typeof(A+a)==Point
    @test typeof(A-a)==Point
    @test typeof(A-B)==Vec
    @test _are_xyz_close(A+a, Point(1.6, -1.0, 2.8))
    @test _are_xyz_close(A+a, a+A)
    @test _are_xyz_close(A-a, Point(0.0, 0.0, 0.0))
    @test _are_xyz_close(A-B, Vec(2.4, -1.0, 2.1))
    @test _are_xyz_close(lambda * a, Vec(1.6, -1.0, 2.8))
    @test _are_xyz_close(lambda * a, a * lambda)
    @test _are_xyz_close(neg(na), Normal(-0.8, 0.5, -1.4))
    @test abs(a*b + 2.51) <= 1e-6 
    @test abs(squared_norm(a) - 2.85) <= 1e-6
    @test abs(norm(a) - 1.6881943016) <= 1e-6
    @test _are_xyz_close(normalize(c), Normal(0.6, 0.8, 0.0))
    @test _are_xyz_close(cross(a,b), Vec(-0.35,-1.68,-0.4))
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
    @test _are_xyz_close(t(p), Point(10.0, 10.0, 10.0))
    @test _are_xyz_close(t(v), v)
    @test _are_xyz_close(rx(p), Point(1.0, -3.0, 2.0))
    @test _are_xyz_close(ry(p), Point(3.0, 2.0, -1.0))
    @test _are_xyz_close(rz(p), Point(-2.0, 1.0, 3.0))
    @test _are_xyz_close(rx(v), Vec(1.0, -3.0, 2.0))
    @test _are_xyz_close(ry(v), Vec(3.0, 2.0, -1.0))
    @test _are_xyz_close(rz(v), Vec(-2.0, 1.0, 3.0))
    @test _are_xyz_close(s(p), Point(2.0, 4.0, 6.0))
    @test _are_xyz_close(s(v), Vec(2.0, 4.0, 6.0))
    @test _are_xyz_close(s2(p), Point(2.0, 6.0, 12.0))
    @test _are_xyz_close(s2(v), Vec(2.0, 6.0, 12.0))
    @test _are_xyz_close(t(o), Vec_to_Point(u))
    @test _are_xyz_close(t(rz(o)), Vec_to_Point(u))
    @test _are_xyz_close(rz(t(o)), Point(-8.0, 9.0, 7.0))
    @test is_consistent(inv_t)
    @test is_consistent(inv_rx)
    @test is_consistent(inv_s2)
    @test _are_xyz_close(inv_t(t(p)), p)
    @test _are_xyz_close(inv_rx(rx(p)), p)
    @test _are_xyz_close(inv_s2(s2(p)), p)

end

@testset "Check ray methods" begin

    p = Point(1.0, 2.0, 3.0)
    v = Vec(1.0, 2.0, 3.0)
    r = Ray(p,v)
    r_2 = Ray(Point(3.0, 6.0, 9.0),v)

    rz = rotation("z", pi/2)
    transformed_ray = Ray(Point(-2.0, 1.0, 3.0),Vec(-2.0, 1.0, 3.0))

    @test _are_xyz_close(at(r,2.0), Point(3.0, 6.0, 9.0))
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

    @test is_close(fire_ray(OC, 0.0, 0.0), OCray)
    @test is_close(fire_ray(PC, 0.0, 0.0), PCray)
    @test aperture_deg(PC) == 2.0 * atan(9.0/16.0) * 180.0 / π

end

@testset "Check ImageTracer methods" begin
    
    vec = Vec(0.0, 0.0, 0.0)
    t = traslation(vec)
    OC = OrthogonalCamera((16.0/9.0), t)
    PC = PerspectiveCamera(1.0, (16.0/9.0), t)
    image = HdrImage(2,3)

    Itracer = ImageTracer(image, PC)
    Itracer2 = ImageTracer(image, PC)

end
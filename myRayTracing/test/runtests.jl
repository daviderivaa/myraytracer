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
    #@test_throws InvalidPfmFileFormat _parse_endianness("-1")

end

@testset "Check _read_line" begin
    
    @test _read_line(IOBuffer([0x70, 0x69, 0x70, 0x70, 0x6F, 0x0A]))=="pippo"
    @test _read_line(IOBuffer([0x70, 0x69, 0x70, 0x70, 0x6F]))=="pippo"

    @test_throws InvalidPfmFileFormat _read_line(IOBuffer([0x0A]))

end


@testset "Check geometry functions" begin

    a = Vec(0.8, -0.5, 1.4)
    b = Vec(-1.6, 0.5, -0.7)
    A = Point(0.8, -0.5, 1.4)
    B = Point(-1.6, 0.5, -0.7)
    na = Normal(0.8, -0.5, 1.4)
    nb = Normal(-1.6, 0.5, -0.7)
    
    lambda = 2.0
    
    @test _are_xyz_close(lambda * a, Vec(1.6, -1.0, 2.8))
    @test _are_xyz_close(cross(a,b), Vec(-0.35,-1.68,-0.4))

end

@testset "Check Transformation functions" begin

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

    @test _are_xyz_close(apply_transf(t, p), Point(10.0, 10.0, 10.0))
    @test _are_xyz_close(apply_transf(t, v), v)
    @test _are_xyz_close(apply_transf(rx, p), Point(1.0, -3.0, 2.0))
    @test _are_xyz_close(apply_transf(ry, p), Point(3.0, 2.0, -1.0))
    @test _are_xyz_close(apply_transf(rz, p), Point(-2.0, 1.0, 3.0))
    @test _are_xyz_close(apply_transf(rx, v), Vec(1.0, -3.0, 2.0))
    @test _are_xyz_close(apply_transf(ry, v), Vec(3.0, 2.0, -1.0))
    @test _are_xyz_close(apply_transf(rz, v), Vec(-2.0, 1.0, 3.0))
    @test _are_xyz_close(apply_transf(s, p), Point(2.0, 4.0, 6.0))
    @test _are_xyz_close(apply_transf(s, v), Vec(2.0, 4.0, 6.0))
    @test _are_xyz_close(apply_transf(s2, p), Point(2.0, 6.0, 12.0))
    @test _are_xyz_close(apply_transf(s2, v), Vec(2.0, 6.0, 12.0))

end
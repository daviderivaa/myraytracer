using myRayTracing
using Test

@testset "Check _read_float" begin
    
    @test _read_float(IOBuffer([0xDB,0x0F,0x49,0x40]), -1)≈3.14159 #Little-endian 
    @test _read_float(IOBuffer([0x40,0x49,0x0F,0xDb]), 1)≈3.14159 #big-endian

end

@testset "Check _parse_endianness" begin

    @test _parse_endianness("1.0")≈1
    @test _parse_endianness("-1.0")≈-1
    
    @test_throws InvalidPfmFileFormat _parse_endianness("0")
    @test_throws InvalidPfmFileFormat _parse_endianness("nan")
    @test_throws InvalidPfmFileFormat _parse_endianness("0.0")
    @test_throws InvalidPfmFileFormat _parse_endianness("2.0")
    @test_throws InvalidPfmFileFormat _parse_endianness("-1")

end
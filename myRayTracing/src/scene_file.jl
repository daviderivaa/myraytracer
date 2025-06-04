###############################################################################
#LEXER AND TOKEN STRUCTS

const WHITESPACE = [' ', '\t', '\n', '\r']
const SYMBOLS = ['(', ')', '<', '>', '[', ']', '{', '}', ',', '*']

"""
mutable struct SourceLocation
    A specific position in a specific file

    - file_name --> name of the file
    - line_num --> specific line in the file
    - col_num --> specific column in the file
end
"""
mutable struct SourceLocation

    file_name::String
    line_num::Int64
    col_num::Int64

    function SourceLocation(file_name::String = "", line_num::Int64 = 0, col_num::Int64 = 0)
        new(file_name, line_num, col_num)
    end

end

"""Abstract type for tokens"""
abstract type AbstractToken end

"""An lexical token, used when parsing a scene file"""
struct Token <: AbstractToken
    location::SourceLocation
end

"""A token for the end of file"""
struct StopToken <: AbstractToken

    location::SourceLocation

    function StopToken(tok::Token)
        new(tok.location)
    end

end

"""All possible keyword recognizible by the lexer with their respective number"""
@enum KeywordEnum begin

    NEW = 1
    MATERIAL = 2
    PLANE = 3
    SPHERE = 4
    DIFFUSE = 5
    SPECULAR = 6
    UNIFORM = 7
    CHECKERED = 8
    IMAGE = 9
    IDENTITY = 10
    TRANSLATION = 11
    ROTATION_X = 12
    ROTATION_Y = 13
    ROTATION_Z = 14
    SCALING = 15
    CAMERA = 16
    ORTHOGONAL = 17
    PERSPECTIVE = 18
    FLOAT = 19
    POINT_LIGHT = 20

end

const KEYWORDS = Dict{String, KeywordEnum}(

    "new" => NEW,
    "material" => MATERIAL,
    "plane" => PLANE,
    "sphere" => SPHERE,
    "diffuse" => DIFFUSE,
    "specular" => SPECULAR,
    "uniform" => UNIFORM,
    "checkered" => CHECKERED,
    "image" => IMAGE,
    "identity" => IDENTITY,
    "translation" => TRANSLATION,
    "rotation_x" => ROTATION_X,
    "rotation_y" => ROTATION_Y,
    "rotation_z" => ROTATION_Z,
    "scaling" => SCALING,
    "camera" => CAMERA,
    "orthogonal" => ORTHOGONAL,
    "perspective" => PERSPECTIVE,
    "float" => FLOAT,
    "point_light" => POINT_LIGHT

)

"""A token containing a Keyword"""
struct KeywordToken <: AbstractToken
    location::SourceLocation
    keyword::KeywordEnum
end

function token_str(t::KeywordToken)
    return string(t.keyword)
end

"""A token containing an Identifier"""
struct IdentifierToken <: AbstractToken
    location::SourceLocation
    identifier::String
end

function token_str(t::IdentifierToken)
    return t.identifier
end

"""A token containing a String"""
struct StringToken <: AbstractToken
    location::SourceLocation
    string::String
end

function token_str(t::StringToken)
    return t.string
end

"""A token containing a LiteralNumber"""
struct LiteralNumberToken <: AbstractToken
    location::SourceLocation
    value::Float64
end

function token_str(t::LiteralNumberToken)
    return t.value
end

"""A token containing a Symbol"""
struct SymbolToken <: AbstractToken
    location::SourceLocation
    symbol::String
end

function token_str(t::SymbolToken)
    return t.symbol
end

"""str functtion for general tokens"""
function token_str(t::AbstractToken)
    return "Token at line $(t.location.line_num)"
end

"""
struct GrammarError <: Exception

    location::SourceLocation --> position of the error
    message::str --> error's message

end
"""
struct GrammarError <: Exception

    location::SourceLocation
    message::str

end

"""
mutable struct InputStream
    Used to parse scene files, it wraps around a stream. It can un-read a token too

    stream::IO
    location::SourceLocation
    saved_char::Union{Char, Nothing}
    saved_location::SourceLocation
    tabulations::Int
    saved_token::Union{AbstractToken, Nothing}

end
"""
mutable struct InputStream

    stream::IO
    location::SourceLocation
    saved_char::Union{Char, Nothing}
    saved_location::SourceLocation
    tabulations::Int
    saved_token::Union{AbstractToken, Nothing}

    function InputStream(stream::IO; file_name::String="", tabulations::Int=8)
        loc = SourceLocation(file_name, 1, 1)
        new(stream, loc, nothing, loc, tabulations, nothing)
    end

end

"""Update the postion after reading a character"""
function update_pos!(input::InputStream, ch::Char)

    if ch == '\n'
        input.location = SourceLocation(input.location.file_name, input.location.line_num + 1, 1)
    elseif ch == '\t'
        input.location = SourceLocation(input.location.file_name, input.location.line_num,
                                       input.location.col_num + input.tabulations)
    else
        input.location = SourceLocation(input.location.file_name, input.location.line_num,
                                       input.location.col_num + 1)
    end

end

"""Read a character"""
function read_char(input::InputStream)::Union{Char, Nothing}

    if input.saved_char !== nothing
        ch = input.saved_char
        input.saved_char = nothing
    else
        bytes = read(input.stream, Char, 1)
        ch = isempty(bytes) ? nothing : bytes[1]
    end

    input.saved_location = input.location
    if ch !== nothing
        update_pos!(input, ch)
    end
    return ch

end

"""Unread a character"""
function unread_char(input::InputStream, ch::Char)

    @assert input.saved_char === nothing "Cannot unread more than one char"
    input.saved_char = ch
    input.location = input.saved_location

end

"""Keep reading till spaces and comments in the file are found"""
function skip_whitespaces_and_comments!(input::InputStream)

    while true
        ch = read_char(input)
        if ch === nothing
            return
        elseif ch in [' ', '\t', '\n', '\r']
            continue
        elseif ch == '#'
            # skip comment until end of line or EOF
            while true
                c = read_char(input)
                if c === nothing || c in ['\r', '\n']
                    break
                end
            end
        else
            unread_char(input, ch)
            return
        end
    end

end

##########################################################################################
# PARSERS

"""Parse a string token"""
function parse_string_token(input::InputStream, token_location::SourceLocation)

    token = IOBuffer()
    while true
        ch = read_char(input)
        if ch === nothing
            throw(GrammarError(token_location, "unterminated string at $token_location"))
        elseif ch == '"'
            break
        else
            write(token, ch)
        end
    end
    return StringToken(token_location, String(take!(token)))

end

"""Parse a float token"""
function parse_float_token(input::InputStream, first_char::Char, token_location::SourceLocation)

    token = IOBuffer()
    write(token, first_char)
    while true
        ch = read_char(input)
        if ch === nothing || !(isdigit(ch) || ch == '.' || ch == 'e' || ch == 'E' || ch == '+' || ch == '-')
            if ch !== nothing
                unread_char(input, ch)
            end
            break
        end
        write(token, ch)
    end

    s = String(take!(token))
    try
        val = parse(Float64, s)
        return LiteralNumberToken(token_location, val)
    catch
        throw(GrammarError(token_location, "Invalid floating-point number '$s' at $token_location"))
    end

end

"""Parse keyword or identifier token"""
function parse_keyword_or_identifier_token(input::InputStream, first_char::Char, token_location::SourceLocation)

    token = IOBuffer()
    write(token, first_char)
    while true
        ch = read_char(input)
        if ch === nothing || !(isalnum(ch) || ch == '_')
            if ch !== nothing
                unread_char(input, ch)
            end
            break
        end
        write(token, ch)
    end
    s = String(take!(token))
    kw = get(KEYWORDS, s, nothing)
    if kw !== nothing
        return KeywordToken(token_location, kw)
    else
        return IdentifierToken(token_location, s)
    end

end

"""Read a general token"""
function read_token(input::InputStream)::AbstractToken

    if input.saved_token !== nothing
        token = input.saved_token
        input.saved_token = nothing
        return token
    end

    skip_whitespaces_and_comments!(input)

    ch = read_char(input)
    if ch === nothing
        return StopToken(input.location)
    end

    token_location = input.location

    if ch in SYMBOLS
        return SymbolToken(token_location, string(ch))
    elseif ch == '"'
        return parse_string_token(input, token_location)
    elseif isdigit(ch) || ch in ['+', '-', '.']
        return parse_float_token(input, ch, token_location)
    elseif isalpha(ch) || ch == '_'
        return parse_keyword_or_identifier_token(input, ch, token_location)
    else
        throw(GrammarError(token_location, "Invalid character '$ch' at $token_location"))
    end

end

"""Unread a token"""
function unread_token(input::InputStream, token::AbstractToken)

    @assert input.saved_token === nothing "Cannot unread more than one token"
    input.saved_token = token

end

"""
mutable struct Scene
    A scene from scene_file

    materials::Dict{String, Material}
    world::World
    camera::Union{Camera, Nothing}
    float_variables::Dict{String, Float64}
    overridden_variables::Set{String}

end
"""
mutable struct Scene

    materials::Dict{String, Material}
    world::World
    camera::Union{Camera, Nothing}
    float_variables::Dict{String, Float64}
    overridden_variables::Set{String}

    function Scene()
        new(Dict{String, Material}(), World(), nothing, Dict{String, Float64}(), Set{String}())
    end

end

"""Verify that the following token is a ymbol"""
function expect_symbol(input_file::InputStream, symbol::String)

    token = read_token(input_file)
    if !(token isa SymbolToken) || token.symbol != symbol
        throw(GrammarError(token.location, "got '$token' instead of '$symbol'"))
    end

end

"""Verify that the following token is a keyword"""
function expect_keywords(input_file::InputStream, keywords::Vector{KeywordEnum})::KeywordEnum

    token = read_token(input_file)
    if !(token isa KeywordToken)
        throw(GrammarError(token.location, "expected a keyword instead of '$token'"))
    end
    if !(token.keyword in keywords)
        expected = join(string.(keywords), ", ")
        throw(GrammarError(token.location, "expected one of the keywords [$expected] instead of '$token'"))
    end
    return token.keyword

end

"""Verify that the following token is a number"""
function expect_number(input_file::InputStream, scene::Scene)::Float64

    token = read_token(input_file)
    if token isa LiteralNumberToken
        return token.value
    elseif token isa IdentifierToken
        name = token.identifier
        if !(haskey(scene.float_variables, name))
            throw(GrammarError(token.location, "unknown variable '$name'"))
        end
        return scene.float_variables[name]
    else
        throw(GrammarError(token.location, "got '$token' instead of a number"))
    end

end

"""Verify that the following token is a string"""
function expect_string(input_file::InputStream)::String

    token = read_token(input_file)
    if !(token isa StringToken)
        throw(GrammarError(token.location, "got '$token' instead of a string"))
    end
    return token.string

end

"""Verify that the following token is an identifier"""
function expect_identifier(input_file::InputStream)::String

    token = read_token(input_file)
    if !(token isa IdentifierToken)
        throw(GrammarError(token.location, "got '$token' instead of an identifier"))
    end
    return token.identifier

end

"""Parse a vector object from tokens"""
function parse_vector(input_file::InputStream, scene::Scene)::Vec

    expect_symbol(input_file, "{")
    x = expect_number(input_file, scene)
    expect_symbol(input_file, ",")
    y = expect_number(input_file, scene)
    expect_symbol(input_file, ",")
    z = expect_number(input_file, scene)
    expect_symbol(input_file, "}")
    return Vec(x, y, z)

end

"""Parse a color object from tokens"""
function parse_color(input_file::InputStream, scene::Scene)::RGB

    expect_symbol(input_file, "<")
    red = expect_number(input_file, scene)
    expect_symbol(input_file, ",")
    green = expect_number(input_file, scene)
    expect_symbol(input_file, ",")
    blue = expect_number(input_file, scene)
    expect_symbol(input_file, ">")
    return RGB(red, green, blue)

end

"""Parse a pigment object from tokens"""
function parse_pigment(input_file::InputStream, scene::Scene)::Pigment

    keyword = expect_keywords(input_file, [UNIFORM, CHECKERED, IMAGE])
    expect_symbol(input_file, "(")

    if keyword == UNIFORM
        color = parse_color(input_file, scene)
        result = UniformPigment(color)

    elseif keyword == CHECKERED
        color1 = parse_color(input_file, scene)
        expect_symbol(input_file, ",")
        color2 = parse_color(input_file, scene)
        expect_symbol(input_file, ",")
        num_of_steps = Int(expect_number(input_file, scene))
        result = CheckeredPigment(color1, color2, num_of_steps)

    elseif keyword == IMAGE
        file_name = expect_string(input_file)
        image = open(file_name, "r") do f
            read_pfm_image(f)
        end
        result = ImagePigment(image)
    end

    expect_symbol(input_file, ")")
    return result

end

"""Parse a BRDF object from tokens"""
function parse_brdf(input_file::InputStream, scene::Scene)::BRDF

    brdf_kw = expect_keywords(input_file, [DIFFUSE, SPECULAR])
    expect_symbol(input_file, "(")
    pigment = parse_pigment(input_file, scene)
    expect_symbol(input_file, ")")

    if brdf_kw == DIFFUSE
        return DiffuseBRDF(pigment)
    elseif brdf_kw == SPECULAR
        return SpecularBRDF(pigment)
    end

end

"""Parse a material object from tokens"""
function parse_material(input_file::InputStream, scene::Scene)::Tuple{String, Material}

    name = expect_identifier(input_file)
    expect_symbol(input_file, "(")
    brdf = parse_brdf(input_file, scene)
    expect_symbol(input_file, ",")
    emitted_radiance = parse_pigment(input_file, scene)
    expect_symbol(input_file, ")")
    return (name, Material(brdf, emitted_radiance))

end

"""Parse a transformation object from tokens"""
function parse_transformation(input_file::InputStream, scene::Scene)::Transformation

    result = Transformation()
    while true
        kw = expect_keywords(input_file, [IDENTITY, TRANSLATION, ROTATION_X, ROTATION_Y, ROTATION_Z, SCALING])
        if kw == IDENTITY
            #do nothing
        elseif kw == TRANSLATION
            expect_symbol(input_file, "[")
            result *= translation(parse_vector(input_file, scene))
            expect_symbol(input_file, "]")
        elseif kw == ROTATION_X
            expect_symbol(input_file, "[")
            result *= rotation_x(expect_number(input_file, scene))
            expect_symbol(input_file, "]")
        elseif kw == ROTATION_Y
            expect_symbol(input_file, "[")
            result *= rotation_y(expect_number(input_file, scene))
            expect_symbol(input_file, "]")
        elseif kw == ROTATION_Z
            expect_symbol(input_file, "[")
            result *= rotation_z(expect_number(input_file, scene))
            expect_symbol(input_file, "]")
        elseif kw == SCALING
            expect_symbol(input_file, "[")
            result *= scaling(parse_vector(input_file, scene))
            expect_symbol(input_file, "]")
        end

        next_tok = read_token(input_file)
        if !(next_tok isa SymbolToken && next_tok.symbol == "*")
            unread_token(input_file, next_tok)
            break
        end
    end
    return result

end

"""Parse a Sphere object from tokens"""
function parse_sphere(input_file::InputStream, scene::Scene)::Sphere

    expect_symbol(input_file, "(")
    material_name = expect_identifier(input_file)
    if !(haskey(scene.materials, material_name))
        throw(GrammarError(input_file.tokens[input_file.pos-1].location, "unknown material $material_name"))
    end
    expect_symbol(input_file, ",")
    transformation = parse_transformation(input_file, scene)
    expect_symbol(input_file, "]")
    return Sphere(transformation, scene.materials[material_name])

end

"""Parse a Plane object from tokens"""
function parse_plane(input_file::InputStream, scene::Scene)::Plane

    expect_symbol(input_file, "(")
    material_name = expect_identifier(input_file)
    if !(haskey(scene.materials, material_name))
        throw(GrammarError(input_file.tokens[input_file.pos-1].location, "unknown material $material_name"))
    end
    expect_symbol(input_file, ",")
    transformation = parse_transformation(input_file, scene)
    expect_symbol(input_file, "]")
    return Plane(transformation, scene.materials[material_name])

end

"""Parse a Camera object from tokens"""
function parse_camera(input_file::InputStream, scene::Scene)::Camera

    expect_symbol(input_file, "(")
    type_kw = expect_keywords(input_file, [PERSPECTIVE, ORTHOGONAL])
    expect_symbol(input_file, ",")
    transformation = parse_transformation(input_file, scene)
    expect_symbol(input_file, ",")
    aspect_ratio = expect_number(input_file, scene)
    expect_symbol(input_file, ",")
    distance = expect_number(input_file, scene)
    expect_symbol(input_file, ")")

    if type_kw == PERSPECTIVE
        return PerspectiveCamera(distance, aspect_ratio, transformation)
    elseif type_kw == ORTHOGONAL
        return OrthogonalCamera(aspect_ratio, transformation)
    end

end

"""Parse a Scene object from tokens"""
function parse_scene(input_file::InputStream, variables::Dict{String, Float64}=Dict())::Scene

    scene = Scene()
    scene.float_variables = copy(variables)
    scene.overridden_variables = Set(keys(variables))

    while true
        what = read_token(input_file)
        if what isa StopToken
            break
        end

        if !(what isa KeywordToken)
            throw(GrammarError(what.location, "At $(what.location): expected a keyword instead of '$(what)'"))
        end

        if what.keyword == FLOAT
            variable_name = expect_identifier(input_file)
            variable_loc = input_file.pos
            expect_symbol(input_file, "(")
            variable_value = expect_number(input_file, scene)
            expect_symbol(input_file, ")")

            if (haskey(scene.float_variables, variable_name) && !(variable_name in scene.overridden_variables))
                throw(GrammarError(variable_loc, "At $(variable_loc): variable «$(variable_name)» cannot be redefined"))
            end

            if !(variable_name in scene.overridden_variables)
                scene.float_variables[variable_name] = variable_value
            end

        elseif what.keyword == SPHERE
            push!(scene.world.shapes, parse_sphere(input_file, scene))
        elseif what.keyword == PLANE
            push!(scene.world.shapes, parse_plane(input_file, scene))
        elseif what.keyword == CAMERA
            if scene.camera !== nothing
                throw(GrammarError(what.location, "At $(what.location): You cannot define more than one camera"))
            end
            scene.camera = parse_camera(input_file, scene)
        elseif what.keyword == MATERIAL
            name, material = parse_material(input_file, scene)
            scene.materials[name] = material
        elseif what.keyword == POINT_LIGHT
            point_light = parse_point_light(input_file, scene)
            push!(scene.world.lights, point_light)
        else
            throw(GrammarError(what.location, "At $(what.location): Unexpected token $(what)"))
        end
    end

    return scene

end
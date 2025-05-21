### PCG STRUCT

"""
Defining PCG struct:

    - state::UInt64 = 0 ---> actual state of the number generator
    - inc::UInt64 = 0 ---> actual inc of the number generator

"""
mutable struct PCG
    state::UInt64
    inc::UInt64
end

"""
function PCG(init_state, init_seq)
    external constructor for PCG (with default values for variables)
"""
function new_PCG(init_state::UInt64 = UInt64(42), init_seq::UInt64 = UInt64(54))
    pcg = PCG(0, 0)
    pcg.state = 0
    pcg.inc = (init_seq << 1) | 1

    random!(pcg)

    pcg.state = pcg.state + init_state

    random!(pcg)

    return pcg
end

"""
function random!(pcg)
    generates a random number and alters the state of the generator
"""
function random!(pcg::PCG)
    oldstate = pcg.state
    pcg.state = oldstate * 6364136223846793005 + pcg.inc
    xorshifted = UInt32( ((oldstate >> 18) ⊻ oldstate) >> 27 & 0xFFFFFFFF)
    rot = UInt32(oldstate >> 59 & 0xFFFFFFFF)

    return UInt32( (xorshifted >> rot) | (xorshifted << ((-rot) & 31)) & 0xFFFFFFFF)
end

"""
function norm_random!(pcg)
    generates a random number between 0 and 1 and alters the state of the generator
"""
function norm_random!(pcg::PCG)
    return Float64( random!(pcg) / 4294967295 )
end
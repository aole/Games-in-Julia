include("go.jl")
using Test

@testset "Illigal Moves" begin
    set_game(["b9","a8"], [], white)
    @test process_input("a9") == false

    state[27] = state[35] = state[45] = 2
    @test process_input("i6") == false

    state[57] = state[59] = state[49] = state[67] = 2
    @test process_input("d4") == false

    set_game(["c7", "d8", "e7", "e6", "d5", "c6"], ["d7"], white)
    @test process_input("d6") == false
    
    set_game(["c7", "d8", "e7", "e6", "d5", "c6"], ["d6"], white)
    @test process_input("d7") == false
    
    set_game(["c7", "d8", "e7", "f6", "e5", "d5", "c6"], ["d7", "e6"], white)
    @test process_input("d6") == false
end

@testset "Captures" begin
    set_game(["b9"], ["a9"], black)
    @test process_input("a8") == true
    @test stone_on("a9") == blank

    set_game(["d1", "e2"], ["e1"], black)
    @test process_input("f1") == true
    @test stone_on("e1") == blank

    set_game(["c7", "d8", "e7"], ["d7"], black)
    @test process_input("d6") == true
    @test stone_on("d7") == blank
    
    set_game(["c7", "d8", "e7", "f6", "e5", "d5"], ["d7", "e6", "d6"], black)
    @test process_input("c6") == true
    @test stone_on("d7") == blank
    @test stone_on("e6") == blank
    @test stone_on("d6") == blank
end

@testset "KO" begin
    set_game(["c7", "d8", "e7", "d6"], ["c6", "e6", "d5"], white)
    @test process_input("d7") == true
    @test stone_on("d6") == blank

    @test process_input("d6") == false
    @test stone_on("d6") == blank

    process_input("a9")
    process_input("b9")
    @test process_input("d6") == true
    @test stone_on("d7") == blank
end

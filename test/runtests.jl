using Test
using PBaB

include("heap_search.jl")

@testset "single-threaded heap search" begin
	bab_finds_min()
	bab_solves_in_root()
	bab_finds_max()
end

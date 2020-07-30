using Test

@testset "GenTeX" begin
	include("evalmd.jl")
	include("latex.jl")
	include("cache.jl")
end

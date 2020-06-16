using Test

@testset "GenTex" begin
	include("evalmd.jl")
	include("latex.jl")
	include("cache.jl")
end

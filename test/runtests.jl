using GenerateMarkdown
using Test

@testset "GenerateMarkdown" begin
	include("evalmd.jl")
	include("latex.jl")
end

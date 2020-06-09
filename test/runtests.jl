using GenerateMarkdown
using Test

# Based on `runtests.jl` from `DataStructures.jl`.
tests = [
	"latex", 
	"evalmd"
	]

if length(ARGS) > 0
	tests = ARGS
end

@testset "GenerateMarkdown" begin
	for t in tests
		fp = joinpath(dirname(@__FILE__), "test_$t.jl")
		println("$fp ...")
		include(fp)
	end
end

using GenerateMarkdown
using Test

@testset "evalmd" begin
	@test ranges(raw"a $x$ and $y$", GenerateMarkdown.inline_regex) == [3:5, 11:13]
	@test ranges(raw"$$x$$, $y$ and $(z)") == [1:5, 8:10, 16:19]
end

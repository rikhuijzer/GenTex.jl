using GenerateMarkdown
using Test

@testset "LaTeX" begin
	text = "a bbb c bbb"
	m = match(r"bbb", text)
	@test replace_with_fn!(text, m, x -> "|$x|") == "a |bbb| c |bbb|"
end

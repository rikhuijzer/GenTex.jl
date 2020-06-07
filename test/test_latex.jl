using GenerateMarkdown
using Test

@testset "LaTeX" begin
	text = "a \(ab\)"
	m = match(r"\\\([^\@]*\\\)", text)
	actual = replace_with_fn!(text, m, x -> "|$x|")
	@test actual == "a |ab|"

	# Smoke test.
	# Do not link to specific `endswith` for now.
	actual = replace_eqs!("@x=1@")
	@test startswith(actual, "<img")
end

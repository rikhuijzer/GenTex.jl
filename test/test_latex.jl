using GenerateMarkdown
using Test

@testset "LaTeX" begin
	text = "a ``a very long sentence``"
	m = match(r"``[^``]*``", text)
	actual = replace_with_fn!(text, m, x -> "|$x|")
	@test actual == "a |a very long sentence|"

	# Smoke test.
	tmpdir = tempname() * '/'
	mkdir(tmpdir)
	@show latex_im!("x=1", tmpdir)
	rm(tmpdir, recursive=true)
end

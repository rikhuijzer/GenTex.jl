using GenerateMarkdown
using Test

@testset "LaTeX" begin
	text = "a ``b``"
	m = match(r"``[^``]*``", text)
	actual = replace_with_fn!(text, m, x -> "|$x|")
	@test actual == "a |b|"

	# Smoke test.
	tmpdir = tempname() * '/'
	mkdir(tmpdir)
	latex_im!("x=1", tmpdir)
	rm(tmpdir, recursive=true)
end

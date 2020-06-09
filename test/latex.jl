using GenerateMarkdown
using Test

@testset "LaTeX" begin
	# Smoke test.
	tmpdir = tempname() * '/'
	mkdir(tmpdir)
	latex_im!(raw"$x=1$", tmpdir)
	rm(tmpdir, recursive=true)
end

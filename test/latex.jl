using GenTex
using Test

@testset "LaTeX" begin
	# Smoke test.
	tmpdir = tempname() * '/'
	mkdir(tmpdir)
	latex_im!(Equation(raw"$x=1$", 1.0, "inline", ""), tmpdir)
	rm(tmpdir, recursive=true)
end

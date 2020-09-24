using GenTeX
using Test

@testset "LaTeX" begin
	# Smoke test.
	# tmpdir = tempname() * '/'
	# mkdir(tmpdir)
	# latex_im(Equation(raw"$x=1$", 1.0, "inline", ""), tmpdir)
	# rm(tmpdir, recursive=true)

    maths = [raw"$a$", raw"\(b\)", raw"$$ c = d $$", raw"\[ e = f \]"]
    s = join(maths, ' ')
    matches = map(x -> string(x.match), eachmatch(GenTeX.latex_regex, s))
    @test maths == matches
end

using GenTeX
using Test

@testset "LaTeX" begin
    maths = [raw"$a$", raw"\(b\)", raw"$$ c = d $$", raw"\[ e = f \]"]
    s = join(maths, ' ')
    matches = map(x -> string(x.match), eachmatch(GenTeX.latex_regex, s))
    @test maths == matches

    tmpdir = tempname() * '/'
    mkdir(tmpdir)
    @test startswith(GenTeX.substitute_latex(raw"$$x_y$$", 1, tmpdir), "<center")
    @test startswith(GenTeX.substitute_latex(raw"$x$", 1, tmpdir), "<img")
    @test startswith(GenTeX.substitute_latex(raw"$$\text{mean} = 1$$", 1, tmpdir), "<center")
    rm(tmpdir, recursive=true)
end

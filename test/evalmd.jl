using GenTeX
using Test

@testset "evalmd" begin
    # TODO: Add test for the following valid display math: $$ \text{for all $i$} $$.
    # TODO: Add test for $$ \n 1 + 1 \n $$.

	@testset "evaluate" begin
		tmpdir = tempname() * '/'
		mkdir(tmpdir)
		@test startswith(GenTeX.substitute_latex(raw"$$x_y$$", 1, tmpdir), "<center")
		@test startswith(GenTeX.substitute_latex(raw"$x$", 1, tmpdir), "<img")
		@test startswith(GenTeX.substitute_latex(raw"$$\text{mean} = 1$$", 1, tmpdir), "<center")
		rm(tmpdir, recursive=true)
	end
end

using GenTeX
using Test

@testset "evalmd" begin
    # TODO: Add test for the following valid display math: $$ \text{for all $i$} $$.
    # TODO: Add test for $$ \n 1 + 1 \n $$.

	@testset "split" begin
		@test GenTeX.ranges(raw"a $x$ and $y$", GenTeX.regexes["inline"]) == [3:5, 11:13]
		@test GenTeX.hits(raw"$$x$$, $y$") == [1:5, 8:10]
		@test GenTeX.splitmd(raw"a $b$ and $$c$$") == ["a ", "\$b\$", " and ", "\$\$c\$\$"]
		@test GenTeX.splitmd(raw"$a$ b") == [raw"$a$", " b"]
		@test GenTeX.allranges(" ") == [1:1]
		@test GenTeX.allranges("") == [1:0]
	end

	@testset "evaluate" begin
		tmpdir = tempname() * '/'
		mkdir(tmpdir)
		@test startswith(GenTeX.substitute_latex(raw"$$x_y$$", 1, tmpdir), "<center")
		@test startswith(GenTeX.substitute_latex(raw"$x$", 1, tmpdir), "<img")
		@test startswith(GenTeX.substitute_latex(raw"$$\text{mean} = 1$$", 1, tmpdir), "<center")
		rm(tmpdir, recursive=true)
	end
end

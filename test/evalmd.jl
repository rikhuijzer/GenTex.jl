using GenTeX
using Test

@testset "evalmd" begin
	@testset "split" begin
		@test GenTeX.ranges(raw"a $x$ and $y$", GenTeX.regexes["inline"]) == [3:5, 11:13]
		@test GenTeX.hits(raw"$$x$$, $y$") == [1:5, 8:10]
		@test splitmd(raw"a $b$ and $$c$$") == ["a ", "\$b\$", " and ", "\$\$c\$\$"]
		@test splitmd(raw"$a$ b") == [raw"$a$", " b"]
		@test GenTeX.allranges(" ") == [1:1]
		@test GenTeX.allranges("") == [1:0]
	end

	@testset "evaluate" begin
		tmpdir = tempname() * '/'
		mkdir(tmpdir)
		@test startswith(substitute_latex(raw"$$x_y$$", 1, tmpdir), "<center")
		@test startswith(substitute_latex(raw"$x$", 1, tmpdir), "<img")
		@test startswith(substitute_latex(raw"$$\text{mean} = 1$$", 1, tmpdir), "<center")
		rm(tmpdir, recursive=true)
	end
end

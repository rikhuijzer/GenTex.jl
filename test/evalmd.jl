using GenTex
using Test

@testset "evalmd" begin
	@testset "split" begin
		@test GenTex.ranges(raw"a $x$ and $y$", GenTex.regexes["inline"]) == [3:5, 11:13]
		@test GenTex.hits(raw"$$x$$, $y$") == [1:5, 8:10]
		@test splitmd(raw"a $b$ and $$c$$") == ["a ", "\$b\$", " and ", "\$\$c\$\$"]
		@test splitmd(raw"$a$ b") == [raw"$a$", " b"]
		@test GenTex.allranges(" ") == [1:1]
		@test GenTex.allranges("") == [1:0]
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

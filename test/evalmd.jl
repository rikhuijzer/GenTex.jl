using GenerateMarkdown
using Test

@testset "evalmd" begin
	@testset "split" begin
		@test GenerateMarkdown.ranges(raw"a $x$ and $y$", GenerateMarkdown.regexes["inline"]) == [3:5, 11:13]
		@test GenerateMarkdown.hits(raw"$$x$$, $y$ and $(z)") == [1:5, 8:10, 16:19]
		@test splitmd(raw"a $b$ and $(c)") == ["a ", "\$b\$", " and ", "\$(c)"]
		@test splitmd(raw"$a$ b") == [raw"$a$", " b"]
		@test GenerateMarkdown.allranges(" ") == [1:1]
		@test GenerateMarkdown.allranges("") == [1:0]
	end

	@testset "evaluate" begin
		@test startswith(substitute_latex(raw"$$x$$"), "<img")
		@test startswith(substitute_latex(raw"$x$"), "<img")
		@test startswith(substitute_latex(raw"$$\text{mean} = 1$$"), "<img")
	end
end

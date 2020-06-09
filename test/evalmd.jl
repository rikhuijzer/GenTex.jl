using GenerateMarkdown
using Test

@testset "evalmd" begin
	@test GenerateMarkdown.ranges(raw"a $x$ and $y$", GenerateMarkdown.regexes["inline"]) == [3:5, 11:13]
	@test GenerateMarkdown.hits(raw"$$x$$, $y$ and $(z)") == [1:5, 8:10, 16:19]
	@test splitmd(raw"a $b$ and $(c)") == ["a ", "\$b\$", " and ", "\$(c)"]
end

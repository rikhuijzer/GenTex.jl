using GenerateMarkdown
using Test

@testset "evalmd" begin
	@test findallstr("zz", "azzbzz") == [2:3, 5:6]
end

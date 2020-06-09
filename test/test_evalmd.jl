using GenerateMarkdown
using Test

@testset "evalmd" begin
	@test findallstr("zz", "zzabzz") == [1:2, 5:6]
end

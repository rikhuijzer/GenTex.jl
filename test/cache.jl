import GenTex
using Test

Cache = GenTex.Cache
DisplayImage = GenTex.DisplayImage

@testset "cache" begin
	tmpdir = tempname() * '/'
	mkdir(tmpdir)

	scale = 1.0
	cache = GenTex.load_cache(scale, tmpdir)
	eq = Equation(raw"$x$", scale, "inline")
	eq_image = DisplayImage(eq, tmpdir, "hash.svg")
	@test GenTex.check_cache(cache, eq) == nothing
	cache = GenTex.update_cache(cache, eq_image)
	@test GenTex.check_cache(cache, eq) == eq_image
	
	GenTex.write_cache!(cache, tmpdir)
	cache = GenTex.load_cache(scale, tmpdir)
	@test GenTex.check_cache(cache, eq) == eq_image
	
	GenTex.clear_cache!(tmpdir)
	cache = GenTex.load_cache(scale, tmpdir)
	@test GenTex.check_cache(cache, eq) == nothing

	rm(tmpdir, recursive=true)
end

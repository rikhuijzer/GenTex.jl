using GenTeX
using Test

DisplayImage = GenTeX.DisplayImage

@testset "cache" begin
	tmpdir = tempname() * '/'
	mkdir(tmpdir)

	scale = 1.0
	cache = GenTeX.load_cache(scale, tmpdir)
	eq = Equation(raw"$x$", scale, "inline", "")
	eq_image = DisplayImage(eq, tmpdir, "hash.svg")
	@test GenTeX.check_cache(cache, eq) == nothing
	GenTeX.update_cache!(cache, eq_image)
	@test GenTeX.check_cache(cache, eq) == eq_image
	eq2 = Equation(raw"$x$", scale, "display", "")
	@test GenTeX.check_cache(cache, eq2) == nothing
	eq3 = Equation(raw"$x$", scale, "inline", "")
	@test GenTeX.check_cache(cache, eq3) == eq_image
	
	GenTeX.write_cache!(cache, tmpdir)
	cache = GenTeX.load_cache(scale, tmpdir)
	@test GenTeX.check_cache(cache, eq) == eq_image
	
	GenTeX.clear_cache!(tmpdir)
	cache = GenTeX.load_cache(scale, tmpdir)
	@test GenTeX.check_cache(cache, eq) == nothing
	rm(tmpdir, recursive=true)

    mkdir(tmpdir)
    substitute_latex(raw"$x$", scale, tmpdir)
	cache = GenTeX.load_cache(scale, tmpdir)
    @test length(cache.images) == 1
    rm(tmpdir, recursive=true)
end

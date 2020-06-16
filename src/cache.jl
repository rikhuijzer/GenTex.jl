import Serialization

struct Cache
	scale::Number
	images::Array{Any,1} # Should be a more specific type.
end

function load_cache(scale::Number, im_dir::AbstractString)::Cache
	if isfile(cache_path(im_dir))
		io = open(cache_path(im_dir), "r") 
		cache = Serialization.deserialize(io)
		close(io)
		if cache.scale == scale 
			return cache
		end
	end
	return Cache(scale, [])
end

function write_cache!(cache::Cache, im_dir::AbstractString)
	open(cache_path(im_dir), "w") do io
		Serialization.serialize(io, cache)
	end
end

clear_cache!(im_dir) = rm(cache_path(im_dir))

function check_cache(cache::Cache, eq::Equation)::Union{DisplayImage,InlineImage,Nothing}
	# Am unable to reproduce this in the test, but do not remove `are_equal`.
	are_equal(eq1::Equation, eq2::Equation)::Bool =
		eq1.text == eq2.text && eq1.scale == eq2.scale && eq1.type == eq2.type

	index = findfirst(eq_image -> are_equal(eq_image.eq, eq), cache.images)
	if index == nothing
		return nothing
	else
		return cache.images[index]
	end
end

update_cache(cache::Cache, eq_image::Union{DisplayImage,InlineImage})::Cache = 
	Cache(cache.scale, [cache.images; eq_image])

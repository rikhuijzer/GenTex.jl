import Serialization

struct Cache
	scale::Number
	images::Array{Union{DisplayImage,InlineImage},1}
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
	index = findfirst(eq_image -> eq_image.eq == eq, cache.images)
	if index == nothing
		return nothing
	else
		return cache.images[index]
	end
end

update_cache(cache::Cache, eq_image::Union{DisplayImage,InlineImage})::Cache = 
	Cache(cache.scale, [cache.images; eq_image])

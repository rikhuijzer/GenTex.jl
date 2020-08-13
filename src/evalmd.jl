struct Equation
	text::AbstractString
	scale::Float64
	type::String # Either `display` or `inline`.
	extra_packages::String # For example, \usepackage{tikz}.
end
export Equation

struct DisplayImage
	eq::Equation
	im_dir::AbstractString
	im_name::AbstractString
end

struct InlineImage
	eq::Equation
	im_dir::AbstractString
	im_name::AbstractString
	# Height could allow for scaling depth if necessary.
	myheight::Float64 # Height according to `.sizes` file.
	mydepth::Float64 # Depth according to `.sizes` file.
end
	
default_im_dir() = joinpath(homedir(), "git", "notes", "static", "latex")
cache_path(im_dir) = joinpath(im_dir, "cache.txt")

regexes = Dict(
	"display" => r"\$\$[^\$]+?\$\$", # For example, $$ x $$.
	"inline" => r"(?<!\$)\$(?!\$).{1}.*?\$" # For example, $x$.
)

"""
Convert a RegexMatch to its start and stop location in a string.
"""
match2range(m::RegexMatch)::UnitRange =
	m.offset:m.offset + (length(m.match) - 1)

"""
Obtain a start and stop location for each regex match for `rx`.
"""
function ranges(s::AbstractString, rx::Regex)::Array{UnitRange,1} 
	# map(println, eachmatch(rx, s))
	map(match2range, eachmatch(rx, s))
end

"""
Obtain a start and stop location for each regex matches in `regexes`.
"""
hits(md::AbstractString)::Array{UnitRange,1} =
	sort(vcat(map(rx -> ranges(md, rx), last.(collect(regexes)))...))

"""
Combine the start and stop locations for regex matches with the ranges in between,
that is, ensure that each position in the string is contained in a range.
"""
function allranges(hits::Array{UnitRange,1}, s::AbstractString)::Array{UnitRange,1}
	if length(hits) == 0
		return [1:length(s)]
	end
	before = 0
	pushfirst!(hits, before:before)
	after = length(s) + 1
	push!(hits, after:after)
	between(i) = hits[i-1].stop+1:hits[i].start-1 
	betweens::Array{UnitRange,1} = map(between, 2:length(hits))
	if betweens[1].stop == before
		betweens = betweens[2:end]
	end
	if betweens[end].start == after
		betweens = betweens[1:end-1]
	end
	hits = hits[2:end-1]
	sort(vcat(hits, betweens))
end
allranges(s::AbstractString) = allranges(hits(s), s)

"""
Return all regex matches for `regexes` and the strings in between the matches,
that is, return a list of strings such that a `join` would return `md` again.
"""
function splitmd(md::AbstractString)
	map(range -> SubString(md, range), allranges(md))
end
export splitmd

function substitute_latex(md::AbstractString, scale::Number, im_dir, extra_packages)
	if !(isdir(im_dir)); mkdir(im_dir) end
	cache = load_cache(scale, im_dir)
	initial_length = length(cache.images)
	parts = splitmd(md)
	for (i, part) in enumerate(parts)
		if startswith(part, raw"$$")	
			(parts[i], cache) = 
				display_eq!(Equation(part, scale, "display", extra_packages), im_dir, cache)
		elseif startswith(part, raw"$")
			(parts[i], cache) = 
				inline_eq!(Equation(part, scale, "inline", extra_packages), im_dir, cache)
		end
	end
	if length(cache.images) != initial_length
		write_cache!(cache, im_dir)
	end
	join(parts)
end
export substitute_latex

function substitute_latex!(frompath, topath; scale=1.6, im_dir="", extra_packages="")::String
	if im_dir == ""; im_dir = default_im_dir(); end
	io = open(frompath, "r") 
	before = read(open(frompath, "r"), String)
	after = substitute_latex(before, scale, im_dir, extra_packages)
	close(io)
	open(topath, "w") do io
		write(io, after)
	end
	topath
end
export substitute_latex!

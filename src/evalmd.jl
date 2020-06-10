regexes = Dict(
	"display" => r"\$\$[^\$]+?\$\$", # For example, $$ x $$.
	# Cannot handle nested parenthesis.
	# Ignored for now since we can define functions above the raw string.
	"eval" => r"\$\(.+?\)", # For example, $(x).
	"inline" => r"\$(?![\(|\$]).{1}\$(?!\$)" # For example, $x$.
)

match2range(m::RegexMatch)::UnitRange =
	m.offset:m.offset + (length(m.match) - 1)

ranges(s::AbstractString, rx::Regex)::Array{UnitRange,1} = 
	map(match2range, eachmatch(rx, s))

hits(md::AbstractString)::Array{UnitRange,1} =
	sort(vcat(map(rx -> ranges(md, rx), last.(collect(regexes)))...))

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

function splitmd(md::AbstractString)
	map(range -> SubString(md, range), allranges(md))
end
export splitmd

function substitute_latex(md::AbstractString)
	parts = splitmd(md)
	for (i, part) in enumerate(parts)
		if startswith(part, raw"$$")	
			parts[i] = display_eq!(part)
		elseif startswith(part, raw"$")
			parts[i] = inline_eq!(part)
		end
	end
	join(parts)
end
export substitute_latex

function substitute_latex!(frompath::String, topath::String)::String
	io = open(frompath, "r") 
	before = read(open(frompath, "r"), String)
	after = substitute_latex(before)
	close(io)
	open(topath, "w") do io
		write(io, after)
	end
	topath
end
export substitute_latex!

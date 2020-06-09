regexes = Dict(
	"display" => r"\$\$[^\$]+?\$\$", # For example, $$ x $$.
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
	before = 0
	pushfirst!(hits, before:before)
	after = length(s) + 1
	push!(hits, after:after)
	between(i) = hits[i-1].stop+1:hits[i].start-1 
	betweens::Array{UnitRange,1} = map(between, 2:length(hits))
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

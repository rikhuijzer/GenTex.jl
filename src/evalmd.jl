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
	hits = pushfirst!(hits, before:before)
	after = length(s) + 1
	hits = push!(hits, after:after)
	between(i) = hits[i].stop+1:hits[i+1].start-1 
	betweens::Array{UnitRange,1} = map(between, 1:length(hits)-1)
	sort(vcat(hits, betweens)[2:end-1])
end
allranges(s::AbstractString) = allranges(hits(s), s)

function splitmd(md::AbstractString)
	@show length(md)
	@show allranges(md)
	# Great. length("a\$b") == 3 != 4.
	# @show map(range -> SubString(md, range), allranges(md))
	"done"
end
export splitmd

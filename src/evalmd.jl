export ranges

display_regex = r"\$\$[^\$]+?\$\$" # For example, $$ x $$.
eval_regex = r"\$\(.+?\)" # For example, $(x).
inline_regex = r"\$(?![\(|\$]).{1}\$(?!\$)" # For example, $x$.

match2range(m::RegexMatch)::UnitRange =
	m.offset:m.offset + (length(m.match) - 1)

ranges(s::AbstractString, rx::Regex)::Array{UnitRange,1} = 
	map(match2range, eachmatch(rx, s))

ranges(md::AbstractString)::Array{UnitRange,1} =
	sort(vcat(map(rx -> ranges(md, rx), [inline_regex, display_regex, eval_regex])...))

function splitmd(md::AbstractString)::Array{AbstractString,1}
	rs = ranges(md)
	
end
export splitmd

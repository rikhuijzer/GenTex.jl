# Using find on strings to avoid using a non-trivial parser.
# For example, it is non-trivial to parse ```a `x` b```.

inline_math_regex = r"\$(?![\(|\$]).{1}\$"
display_math_regex = r"\$\$[^\$]+?\$\$"
eval_regex = r"\$\(.+?\)"

function findallstr(pattern::AbstractString, s)
	ranges::Array{UnitRange,1} = []
	result = 0:0
	while (result = findnext(pattern, s, result.stop + 1)) != nothing
		push!(ranges, result)
	end
	ranges
end
findallstr(pattern::Char, s::AbstractString) = findallstr(string(pattern), s)
export findallstr

function ranges(md::AbstractString)::Array{Range,1}
	ranges = []
	dollar_hits = findallstr("\$", md)
	display_hits = findallstr("\$\$", md)
	foreach(i -> push!(ranges, display_hits[2*i], 
	for i in 1:display_hits/2
			
	end
	ranges
end

function splitmd(md::AbstractString)::Array{AbstractString,1}
	rs = ranges(md)
	
end
export splitmd

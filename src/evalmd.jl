struct Range
	a::Int
	b::Int
end
export Range

# I need a lookahead parser for ```a `x` b```.

function findallstr(pattern::AbstractString, string::AbstractString)
	ranges::Array{UnitRange,1} = []
	result = 1:1
	while (result = findnext(pattern, string, result.stop + 1)) != nothing
		push!(ranges, result)
	end
	ranges
end
export findallstr

function ranges(md::AbstractString)::Array{Range,1}
	dollar_hits = 3
end

function splitmd(md::AbstractString)::Array{AbstractString,1}
	rs = ranges(md)
	
end
export splitmd

struct Equation
	text::AbstractString
	scale::Float64
	project_name::AbstractString
end
export Equation

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

function substitute_latex(md::AbstractString, project_name, scale::Float64)
	parts = splitmd(md)
	for (i, part) in enumerate(parts)
		if startswith(part, raw"$$")	
			parts[i] = display_eq!(Equation(part, scale, project_name))
		elseif startswith(part, raw"$")
			parts[i] = inline_eq!(Equation(part, scale, project_name))
		end
	end
	join(parts)
end
export substitute_latex

function substitute_latex!(frompath, topath, project_name; scale=1.0)::String
	io = open(frompath, "r") 
	before = read(open(frompath, "r"), String)
	after = substitute_latex(before, project_name, scale)
	close(io)
	open(topath, "w") do io
		write(io, after)
	end
	topath
end
export substitute_latex!

function show_example!() 
	example = raw"""
	---
	title: LaTeX demo
	---
	# Demo
	This is an example text with $x$, $x_2$, $x^3$ and $u \cdot v$.
	
	$$ y = \frac{a + 1}{b + 1^2} $$

	"""
	out_path = joinpath(homedir(), "git", "notes", "content", "docs", "jmd", "example.md")
	tmpdir = tempname(cleanup=false) * '/'
	mkdir(tmpdir)
	project_name = "example"
	temp = joinpath(tmpdir, "$project_name.md")
	open(temp, "w") do io
		write(io, example)
	end
	substitute_latex!(temp, out_path, project_name)
	rm(tmpdir, recursive=true)
	println("File written - $(Dates.Time(Dates.now()))"[1:end-4])
end
export show_example!

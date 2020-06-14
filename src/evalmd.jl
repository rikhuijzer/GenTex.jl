struct Equation
	text::AbstractString
	scale::Float64
	type::String # Either `display` or `inline`.
end
export Equation

struct DisplayEquationImage
	eq::Equation
	im_dir::AbstractString
	im_name::AbstractString
end

struct InlineEquationImage
	eq::Equation
	im_dir::AbstractString
	im_name::AbstractString
	# Height could allow for scaling depth if necessary.
	myheight::Float64 # Height according to `.sizes` file.
	mydepth::Float64 # Depth according to `.sizes` file.
end

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

function substitute_latex(md::AbstractString, scale::Float64)
	parts = splitmd(md)
	for (i, part) in enumerate(parts)
		if startswith(part, raw"$$")	
			parts[i] = display_eq!(Equation(part, scale, "display"))
		elseif startswith(part, raw"$")
			parts[i] = inline_eq!(Equation(part, scale, "inline"))
		end
	end
	join(parts)
end
export substitute_latex

function substitute_latex!(frompath, topath; scale=1.0)::String
	io = open(frompath, "r") 
	before = read(open(frompath, "r"), String)
	after = substitute_latex(before, scale)
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

	We could also write $\frac{z}{2}$ where $z = \{ 1, 2, ..., u \}$.

	"""
	out_path = joinpath(homedir(), "git", "notes", "content", "docs", "jmd", "example.md")
	tmpdir = tempname(cleanup=false) * '/'
	mkdir(tmpdir)
	temp = joinpath(tmpdir, "example.md")
	open(temp, "w") do io
		write(io, example)
	end
	substitute_latex!(temp, out_path, scale=1.6)
	rm(tmpdir, recursive=true)
	println("File written - $(Dates.Time(Dates.now()))"[1:end-4])
end
export show_example!

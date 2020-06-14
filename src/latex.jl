using Dates
using Memoize

floatregex = "([0-9]*[.])?[0-9]+"
match2num(m::RegexMatch) = parse(Float64, match(Regex(floatregex), m.match).match)

preamble = raw"""
	\documentclass[12pt]{article}
	\nonstopmode
	\usepackage{amsmath}
	\usepackage{amssymb}
	\pagestyle{empty}"""

function wrap_eq(eq::Equation)::String
	if eq.type == "display"
		# The `lrbox` errors on display math (`$$ ... $$`).
		return string(
			preamble, """
			\\begin{document}
			$(eq.text)
			\\end{document}"""
		)
	else 
		# Using the `lrbox` to determine the baseline and resulting depth.
		# Source: http://mactextoolbox.sourceforge.net/articles/baseline.html
		return string(
			preamble, 
			raw"""
			\newsavebox{\mybox}
			\newlength{\mywidth}
			\newlength{\myheight}
			\newlength{\mydepth}
			\begin{lrbox}{\mybox}
			""",
			eq.text, '\n',
			raw"""
			\end{lrbox}
			\settowidth {\mywidth}  {\usebox{\mybox}}
			\settoheight{\myheight} {\usebox{\mybox}}
			\settodepth {\mydepth}  {\usebox{\mybox}}
			\newwrite\foo
			\immediate\openout\foo=\jobname.sizes
				\immediate\write\foo{Depth = \the\mydepth}
				\immediate\write\foo{Height = \the\myheight}
				\addtolength{\myheight} {\mydepth}
				\immediate\write\foo{TotalHeight = \the\myheight}
				\immediate\write\foo{Width = \the\mywidth}
			\closeout\foo
			\begin{document}
			\usebox{\mybox}
			\end{document}""")
	end
end

@memoize function check_latex()
	try 
		run(pipeline(`pdflatex --help`, devnull))
	catch 
		throw(ErrorException("Failed to run pdflatex"))
	end
end

function get_sizes(path::AbstractString)::Tuple{Float64,Float64}
	io = open(path, "r")
	sizes = read(io, String)
	close(io)
	height = match(Regex("TotalHeight = $(floatregex)pt"), sizes)
	depth = match(Regex("Depth = $(floatregex)pt"), sizes)
	(match2num(height), match2num(depth))
end

"""
Generate an image from latex code.
"""
function latex_im!(eq::Equation, im_dir::String)
	check_latex()
	tmpdir = tempname() * '/'
	mkdir(tmpdir)
	file(extension) = joinpath(tmpdir * "eq.$extension")
	open(file("tex"), "w") do io
		write(io, wrap_eq(eq))
	end
	old_pwd = pwd()
	# pdflatex uses current working directory to store intermediate files.
	cd(tmpdir)
	pdflatex = `pdflatex $(file("tex"))`
	mktemp() do path, file
		try
			run(pipeline(pdflatex, stdout=path, stderr=devnull))
		catch e
			open(path, "r") do io
				println(read(path, String))
			end
			throw(ErrorException("""Failed to run pdflatex on 
				$(wrap_eq(eq))
				"""))
		end
	end
	crop = `pdfcrop $(file("pdf")) $(file("crop.pdf"))`
	try
		run(pipeline(crop, stdout=devnull, stderr=devnull))
	catch e
		throw(ErrorException("Failed to run pdfcrop. Is pdfcrop installed?"))
	end
	pdf2svg = `dvisvgm --pdf $(file("crop.pdf"))`
	try
		run(pipeline(pdf2svg, stdout=devnull, stderr=devnull))
	catch e
		throw(ErrorException("Failed to run dvisvgm. Is dvisvgm installed?"))
	end
	mv(file("crop"), file("svg"))
	tmpfilename = split(tmpdir, '/')[end-1]
	im_name = "$(hash(eq.text)).svg"
	# Make sure to write all LaTeX images for one (static) website to the same
	# directory. That, in combination with the hash function, will allow the 
	# browser to reuse LaTeX accross pages which reduces page loading time.
	im_path = joinpath(im_dir, im_name)
	mv(file("svg"), im_path, force=true)
	cd(old_pwd)
	if eq.type == "display"
		eq_image = DisplayEquationImage(eq, im_dir, im_name)
	else
		(height, depth) = get_sizes(file("sizes"))
		eq_image =  InlineEquationImage(eq, im_dir, im_name, height, depth)
	end
	rm(tmpdir, recursive=true)
	return eq_image
end
export latex_im!

function dimensions(svg_path::AbstractString)::Tuple{Float64,Float64}
	io = open(svg_path, "r")
	svg = read(io, String)
	close(io)
	w = match(Regex("width='$(floatregex)pt'"), svg)
	h = match(Regex("height='$(floatregex)pt'"), svg)
	return (match2num(w), match2num(h))
end

function determine_param(eq::Equation, eq_image)::Array{String,1}
	link = '/' * joinpath("latex", eq_image.im_name)
	im_path = joinpath(eq_image.im_dir, eq_image.im_name)
	(w, h) = dimensions(im_path)
	width = round(eq.scale * w; digits=3)
	height = round(eq.scale * h; digits=3)
	params = [
		"src=\"$(link)\"",
		"width=\"$(width)\"",
		"height=\"$(height)\""
	]
	if eq.type == "inline"
		valign = round(eq.scale * (eq_image.mydepth); digits=3)
		style = "style=\"margin:0;vertical-align:-$(valign)px\""
		push!(params, style)
	end
	return params
end

@memoize function _eq!(eq::Equation)
	# TODO: Pass this dir.
	im_dir = joinpath(homedir(), "git", "notes", "static", "latex")
	if !(isdir(im_dir)); mkdir(im_dir) end
	eq_image = latex_im!(eq, im_dir)
	param = determine_param(eq, eq_image)
	img = """<img $(join(param, ' '))>"""
	startswith(eq.text, "\$\$") ? "<center>$(img)</center>" : img
end

display_eq!(eq::Equation)::String = 
	_eq!(eq)
export display_eq!
inline_eq!(eq::Equation)::String =
	_eq!(eq)
export inline_eq!


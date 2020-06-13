using Base64
using Dates
using Memoize

struct Equation
	text::AbstractString
	scale::Float64
end

preamble = """
\\documentclass[12pt]{article}
\\nonstopmode
\\pagestyle{empty}
\\usepackage{amsmath}"""

wrap_eq(equation::AbstractString)::String = """
	$(preamble)
	\\begin{document}
	$(equation)
	\\end{document}"""	

@memoize function check_latex()
	try 
		run(pipeline(`pdflatex --help`, devnull))
	catch 
		throw(ErrorException("Failed to run pdflatex"))
	end
end

"""
Generate an image from latex code.
"""
# @memoize 
function latex_im!(latex::AbstractString, im_dir::String)
	check_latex()
	tmpdir = tempname() * '/'
	mkdir(tmpdir)
	file(extension) = joinpath(tmpdir * "eq.$extension")
	open(file("tex"), "w") do io
		write(io, wrap_eq(latex))
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
				$(wrap_eq(latex))
				"""))
		end
	end
	crop = `pdfcrop $(file("pdf")) $(file("crop.pdf"))`
	# convert = `convert -density 300 $(file("pdf")) -quality 95 $(file("png"))`
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
	imfilename = joinpath(im_dir, tmpfilename * ".svg")
	mv(file("svg"), imfilename)
	cd(old_pwd)
	rm(tmpdir, recursive=true)
	return tmpfilename * ".svg"
end
export latex_im!

function _eq!(equation::AbstractString, class::String; param="")
	im_dir = joinpath(homedir(), "git", "notes", "static", "gen_im")
	if !(isdir(im_dir)); mkdir(im_dir) end
	im_name = latex_im!(equation, im_dir)
	link = '/' * joinpath("gen_im", im_name)
	"""<img class="$(class)" $(param) src="$(link)">"""
end

display_eq!(eq::AbstractString)::String = 
	_eq!(eq, "display-math")
export display_eq!
inline_eq!(eq::AbstractString)::String = 
	_eq!(eq, "inline-math")
export inline_eq!



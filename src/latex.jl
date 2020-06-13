using Base64
using Dates
using Memoize


preamble = """
\\documentclass[12pt]{article}
\\nonstopmode
\\pagestyle{empty}
\\usepackage{amsmath}"""

wrap_eq(eq::Equation)::String = """
	$(preamble)
	\\begin{document}
	$(eq.text)
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
				$(wrap_eq(latex))
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
	imfilename = joinpath(im_dir, im_name)
	mv(file("svg"), imfilename, force=true)
	cd(old_pwd)
	rm(tmpdir, recursive=true)
	return im_name
end
export latex_im!

function determine_param(eq::Equation, im_dir, im_name)::Array{String,1}
	link = '/' * joinpath("latex", im_name)
	@show im_dir, im_name
	
	return [
		"src=\"$(link)\""
	]
end

function _eq!(eq::Equation, class::String)
	# TODO: Pass this dir.
	im_dir = joinpath(homedir(), "git", "notes", "static", "latex")
	if !(isdir(im_dir)); mkdir(im_dir) end
	im_name = latex_im!(eq, im_dir)
	param = determine_param(eq, im_dir, im_name)
	img = """<img class="$(class)" $(join(param, ' '))>"""
	startswith(eq.text, "\$\$") ? "<center>$(img)</center>" : img
end

display_eq!(eq::Equation)::String = 
	_eq!(eq, "display-math")
export display_eq!
inline_eq!(eq::Equation)::String =
	_eq!(eq, "inline-math")
export inline_eq!


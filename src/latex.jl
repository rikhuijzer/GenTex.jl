using Base64
using Memoize

tex_header = """
\\documentclass[convert={density=300,size=800x800,outext=.png}]{standalone}
\\nonstopmode
\\usepackage{amsmath}
\\begin{document}"""

function wrap_eq(equation::AbstractString)::String
	# TODO: Make struct for (equation, displaystyle).
	if startswith(equation, raw"$$") 
		displaystyle = true
		equation = equation[3:end-2]
	elseif startswith(equation, raw"$")
		displaystyle = false
		equation = equation[2:end-1]
	end

	# Based on https://tex.stackexchange.com/questions/50162.
	return """
	$(tex_header)
	\$ $(displaystyle ? "\\displaystyle " : "")
	$(equation)
	\$
	\\end{document}"""	
end

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
@memoize function latex_im!(latex::AbstractString, im_dir::String)
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
	convert = `convert -density 300 $(file("pdf")) -quality 95 $(file("png"))`
	try
		run(Base.CmdRedirect(convert, devnull, 2, false))
	catch e
		throw(ErrorException("Failed to run convert. Is ImageMagick installed?"))
	end
	tmpfilename = split(tmpdir, '/')[end-1]
	imfilename = joinpath(im_dir, tmpfilename * ".png")
	mv(file("png"), imfilename)
	cd(old_pwd)
	rm(tmpdir, recursive=true)
	return tmpfilename * ".png"
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
	_eq!(eq, "inline-math"; param="height=\"13\"")
export inline_eq!

"""
Replace a match by applying a function to it.
"""
function replace_with_fn!(text::String, m::RegexMatch, fn)::String
	before = text[1:m.offset - 1]
	equation = m.match[3:end-2]
	after = text[m.offset + length(m.match):end]
	before * fn(equation) * after
end
export replace_with_fn!

function replace_eqs!(text) 
	matches = eachmatch(r"``[^``]*``", text)
	for m in reverse(collect(matches))
		text = replace_with_fn!(text, m, inline_eq)
	end
	text
end
export replace_eqs!

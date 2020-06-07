using Base64
using Memoize

wrap_eq(equation::AbstractString)::String = """
\\documentclass[convert={density=300,size=800x800,outext=.png}]{standalone}
\\begin{document}
\$ $equation \$
\\end{document}"""	

"""
Generate an image from latex code.
"""
@memoize function latex_im!(latex::AbstractString, im_dir::String)
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
	try
		run(Base.CmdRedirect(pdflatex, devnull, 1, true))
	catch e
		throw(ErrorException("Failed to run pdflatex. Is LaTeX installed?"))
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
	return imfilename
end
export latex_im!

function inline_eq(equation::AbstractString)::String
	encoded = base64_latex(equation)
	"\n<img class='display-math' src='$(encoded)'>\n"
end
export inline_eq

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
	match = collect(matches)[1]
	for m in matches
		text = replace_with_fn!(text, m, inline_eq)
	end
	text
end
export replace_eqs!

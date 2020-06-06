wrap_eq(equation::AbstractString)::String = """
\\documentclass[convert={density=300,size=800x800,outext=.png}]{standalone}
\\begin{document}
$equation
\\end{document}"""	

"""
Generate an inline LaTeX equation.
"""
function inline_eq(equation::AbstractString)::String
	mktemp() do path, io
		write(io, wrap_eq(equation))
		close(io)
		cd(tempdir()) 
		run(`pdflatex $path -shell-escape`)
		run(`convert -density 300 $(path * ".pdf") -quality 95 $(path * ".png")`)
		println(path)
		run(`rm $(path)*`) # Fix this. Dont know whats wrong.
	end
	"foobar"
end
export inline_equation

"""
Replace a match by applying a function to it.
"""
function replace_with_fn!(text::String, m::RegexMatch, fn)::String
	before = text[1:m.offset - 1]
	equation = m.match[2:end-1]
	after = text[m.offset + length(m.match):end]
	before * fn(equation) * after
end

function replace_eqs!(text) 
	matches = eachmatch(r"\@(.?+)\@", text)
	match = collect(matches)[1]
	for m in matches
		text = replace_with_fn!(text, m, inline_eq)
	end
	text
end
export replace_eqs!

tmp() = println(inline_eq("x = 1"))
export tmp

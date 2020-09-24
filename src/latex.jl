using Dates

export
    latex_im

# Source: https://stackoverflow.com/questions/14182879.
latex_regex = r"(?<!\\)    # negative look-behind to make sure start is not escaped 
    (?:        # start non-capture group for all possible match starts
      # group 1, match dollar signs only 
      # single or double dollar sign enforced by look-arounds
      ((?<!\$)\${1,2}(?!\$))|
      # group 2, match escaped parenthesis
      (\\\()|
      # group 3, match escaped bracket
      (\\\[)|                 
      # group 4, match begin equation
      (\\begin\{equation\})
    )
    # if group 1 was start
    (?(1)
      # non greedy match everything in between
      # group 1 matches do not support recursion
      (.*?)(?<!\\)
      # match ending double or single dollar signs
      (?<!\$)\1(?!\$)|  
    # else
    (?:
      # greedily and recursively match everything in between
      # groups 2, 3 and 4 support recursion
      (.*(?R)?.*)(?<!\\)
      (?:
        # if group 2 was start, escaped parenthesis is end
        (?(2)\\\)|  
        # if group 3 was start, escaped bracket is end
        (?(3)\\\]|     
        # else group 4 was start, match end equation
        \\end\{equation\}
      )
    ))))"x

floatregex = "([0-9]*[.])?[0-9]+"
match2num(m::RegexMatch) = parse(Float64, match(Regex(floatregex), m.match).match)

preamble(extra_packages="") = """
    \\documentclass[12pt]{article}
    \\nonstopmode
    \\usepackage{amsmath}
    \\usepackage{amssymb}
    $(extra_packages)
    \\pagestyle{empty}"""

function wrap_eq(eq::Equation)::String
    if eq.type == "display"
        # The `lrbox` errors on display math (`$$ ... $$`).
        return string(
            preamble(eq.extra_packages), """
            \\begin{document}
            $(eq.text)
            \\end{document}"""
        )
    else 
        # Using the `lrbox` to determine the baseline and resulting depth.
        # Source: http://mactextoolbox.sourceforge.net/articles/baseline.html
        return string(
            preamble(eq.extra_packages), raw"""
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
            \end{document}"""
        )
    end
end

function check_latex()
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
function latex_im(eq::Equation, im_dir::String)
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
        eq_image = DisplayImage(eq, im_dir, im_name)
    else
        (height, depth) = get_sizes(file("sizes"))
        eq_image =  InlineImage(eq, im_dir, im_name, height, depth)
    end
    rm(tmpdir, recursive=true)
    return eq_image
end

function dimensions(svg_path::AbstractString)::Tuple{Float64,Float64}
    svg = ""
    try 
        io = open(svg_path, "r")
        svg = read(io, String)
        close(io)
    catch
        throw(ErrorException("Failed to read file. Is the cache invalid?"))
    end
    w = match(Regex("width='$(floatregex)pt'"), svg)
    h = match(Regex("height='$(floatregex)pt'"), svg)
    return (match2num(w), match2num(h))
end

function determine_param(eq_image)::Array{String,1}
    link = '/' * joinpath("latex", eq_image.im_name)
    im_path = joinpath(eq_image.im_dir, eq_image.im_name)
    (w, h) = dimensions(im_path)
    width = round(eq_image.eq.scale * w; digits=3)
    height = round(eq_image.eq.scale * h; digits=3)
    params = [
        "src=\"$(link)\"",
        "width=\"$(width)\"",
        "height=\"$(height)\""
    ]
    if eq_image.eq.type == "inline"
        valign = round(eq_image.eq.scale * (eq_image.mydepth); digits=3)
        style = "style=\"margin:0;vertical-align:-$(valign)px\""
        push!(params, style)
    end
    return params
end

function _eq!(eq::Equation, im_dir, cache)::Tuple{String,Cache}
    eq_image = check_cache(cache, eq)
    if eq_image == nothing
        eq_image = latex_im(eq, im_dir)
        cache = update_cache(cache, eq_image)
    end
    param = determine_param(eq_image)
    img = """<img $(join(param, ' '))>"""
    s = eq.type == "display" ? "<center>$(img)</center>" : img
    (s, cache)
end

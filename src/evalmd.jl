export
    Equation,
    substitute_latex

struct Equation
	text::AbstractString
	scale::Float64
	type::String # Either `display` or `inline`.
	extra_packages::String # For example, \usepackage{tikz}.
end

struct DisplayImage
	eq::Equation
	im_dir::AbstractString
	im_name::AbstractString
end

struct InlineImage
	eq::Equation
	im_dir::AbstractString
	im_name::AbstractString
	# Height could allow for scaling depth if necessary.
	myheight::Float64 # Height according to `.sizes` file.
	mydepth::Float64 # Depth according to `.sizes` file.
end
	
default_im_dir() = joinpath(homedir(), "git", "notes", "static", "latex")
cache_path(im_dir) = joinpath(im_dir, "cache.txt")

function eq_replace!(cache, eq::SubString, scale, im_dir, extra_packages)::String
    eq_type = (startswith(eq, raw"$$") || startswith(eq, raw"\[") || startswith(eq, raw"\begin{eq")) ? 
        "display" : "inline"
    (new, cache) = _eq!(Equation(eq, scale, eq_type, extra_packages), im_dir, cache)
    new
end

"""
    substitute_latex(md::AbstractString, scale::Number, im_dir; extra_packages="")::String

Substitute LaTeX in Markdown string `md`.
The LaTeX images will be placed at `im_dir/<h>.svg` where `h` is a hash calculated over the math expression.
The benefit of using a hash is that the browser downloads only one image per math expression.
Image size can be tweaked by setting `scale`.
"""
function substitute_latex(md::AbstractString, scale::Number, im_dir; extra_packages="")::String
	if !(isdir(im_dir)); mkdir(im_dir) end
	cache = load_cache(scale, im_dir)
	initial_cache_length = length(cache.images)

    md = replace(md, latex_regex => m -> eq_replace!(cache, m, scale, im_dir, extra_packages))

	if length(cache.images) != initial_cache_length
		write_cache!(cache, im_dir)
	end
	md
end

function substitute_latex!(frompath, topath; scale=1.6, im_dir="", extra_packages="")::String
	if im_dir == ""; im_dir = default_im_dir(); end
	io = open(frompath, "r") 
	before = read(open(frompath, "r"), String)
	after = substitute_latex(before, scale, im_dir, extra_packages)
	close(io)
	open(topath, "w") do io
		write(io, after)
	end
	topath
end

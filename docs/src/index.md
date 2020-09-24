# GenTeX.jl

The most important function is `substitute_latex`.

```@docs
substitute_latex
```

It substitutes LaTeX as HTML in Markdown strings.
Note that GenTeX can only support alignment and scaling on Markdown parsers with support for raw HTML.
This is not supported by Julia's Markdown parser.

## Simple example 

Below is a simple example in Julia Markdown.

```@setup 1
using GenTeX
dirparent(path)::String = splitdir(endswith(path, '/') ? path[1:end-1] : path)[1]
dirparent(path, n)::String = ∘(repeat([dirparent], n)...)(path)
project_root()::String = dirparent(pathof(GenTeX), 2)
im_dir = joinpath(project_root(), "docs", "build", "latex")
```

```@example 1
substitute_latex(raw"$u$ and $v$", 1, im_dir) 
```

![](latex/15834477068757624619.svg) and ![](latex/14086325667262365765.svg)

## Full example

For a more complete example with proper alignment and scaling, see <https://huijzer.xyz/posts/correlations>.
The source code is available at <https://github.com/rikhuijzer/site>.


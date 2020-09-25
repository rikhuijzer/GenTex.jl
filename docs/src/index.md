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

```@example 1 
using GenTeX
tmpdir = tempname() * '/'
mkdir(tmpdir)
md = substitute_latex(raw"$u$ and $v$", 1, tmpdir) 
rm(tmpdir, recursive=true)
md
```

## Full example

For a more complete example with proper alignment and scaling, see <https://huijzer.xyz/posts/correlations>.
The source code is available at <https://github.com/rikhuijzer/site>.

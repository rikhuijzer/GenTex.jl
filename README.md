<h1 align="center">
  GenTeX
</h1>

<h3 align="center">
  Generate LaTeX images
</h3>

This is a wrapper around `pdflatex`, `pdfcrop` and `dvisvgm` (to obtain SVG images) and is based on [latex-formulae](https://github.com/liamoc/latex-formulae).
Benefits of rendering LaTeX to images are to

- allow full LaTeX capabilities, such as using TikZ and
- avoid JavaScript on the client-side.

Generating LaTeX images is slow.
Therefore, this project implements a in-memory cache which is also stored to disk.
This is useful for speeding up local development and GitHub workflows.

For most use-cases, I would advise [Franklin.jl](https://github.com/tlienart/Franklin.jl).

## Installation

In the Julia REPL, GenTeX can be installed by hitting `]` to enter the Pkg mode:

```
julia> ]

pkg> add GenTeX
```

Alternatively, use 
```
using Pkg
Pkg.add("GenTeX")
```

## Syntax

The full LaTeX syntax is supported since the math expressions are passed into `pdflatex`.
However, it is quite tricky to detect which parts of a string need to be interpreted as LaTeX.
A regular expression is used; it can detect at least the following LaTeX expressions.

```jl
text = raw"""
  First, $ex$ and \(ex\) with
  
  $$ ex $$
  
  and
  
  \[ ex \]
  
  Also, 
  
  $$
  ex
  $$
  
  and 
  
  \[
  ex
  \]
  """
```

When you want to combine LaTeX with Julia's string interpolation, you cannot use a raw string.
The shortest is then to use `\$` for inline math and `\\[` for display math.

```jl
"
1 + 1 = $(1 + 1)
since
\$ex\$
and
\\[
  ex
\\]
"
```

## Licenses

This package is MIT licensed since it seems to be the default for Julia packages.

**External:**

- This project is loosely based on [latex-formulae](https://github.com/liamoc/latex-formulae/blob/master/LICENSE)

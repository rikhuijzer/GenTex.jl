<h1 align="center">
  GenTeX
</h1>

<h3 align="center">
  Generate LaTeX images
</h3>

This is a wrapper around `pdflatex`, `pdfcrop` and `dvisvgm` (to obtain SVG images).
Benefits of rendering LaTeX to images are to

- allow full LaTeX capabilities, such as using TikZ and
- avoid JavaScript on the client-side.

Generating LaTeX images is slow.
Therefore, this project implements a in-memory cache which is also stored to disk.
This is useful for speeding up local development and GitHub workflows.

## Installation

You can obtain GenTeX using Julia's Pkg REPL-mode (hitting ] as the first character of the command prompt):
In the Julia REPL, GenTeX can be installed by hitting `]` to enter the Pkg mode:

```
julia> ]

(v1.0) pkg> add GenTeX
```

Alternatively, use 
```
using Pkg 

Pkg.add("GenTeX")
```

## Demo

My blog uses this package.
For example, see

- https://huijzer.xyz/posts/correlations for some math or
- https://huijzer.xyz/about-site/ for a TikZ picture.

The source code is at <https://github.com/rikhuijzer/site>.

For a simple example, see the [documentation](https://rikhuijzer.github.io/GenTeX.jl/dev/).

## Syntax

The full LaTeX syntax is supported since the math expressions are passed into `pdflatex`.
However, it is quite tricky to detect which parts of a string need to be interpreted as LaTeX.
A regular expression is used which can detect at least the following expressions:

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

To combine LaTeX with Julia's string interpolation, avoid using a raw string.
The shortest is then to use `\$` for inline math and `\\[` for display math.

```jl
"
\$ex\$
and
\\[
  ex
\\]
"
```

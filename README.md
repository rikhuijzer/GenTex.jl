<h1 align="center">
  GenTeX
</h1>

<h3 align="center">
  Generate LaTeX images for websites
</h3>


Benefits of rendering LaTeX to images are to

- avoid JavaScript on the client-side and
- allow full LaTeX capabilities, such as using the `tikz` package.

Generating LaTeX images is slow.
Therefore, this project implements a in-memory cache which is also stored to disk.
This is useful for speeding up local development and GitHub workflows.

## Demo

My blog uses this package.
For example, see

- https://huijzer.xyz/posts/correlations for some math or
- https://huijzer.xyz/about-site/ for a Tikz picture.

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

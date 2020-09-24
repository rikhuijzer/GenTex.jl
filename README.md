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
Therefore, this project implements a file-based cache.
This is useful for local development and for building via GitHub workflows.

## Demo

My blog uses this package.
For example, see

- https://huijzer.xyz/posts/correlations for some math or
- https://huijzer.xyz/about-site/ for a Tikz picture.

The source code is at <https://github.com/rikhuijzer/site>.

For a simple example, see the [documentation](https://rikhuijzer.github.io/GenTeX.jl/dev/).

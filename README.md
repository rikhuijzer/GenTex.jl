<h1 align="center">
  GenTeX
</h1>

<h3 align="center">
  Generate LaTeX images for websites
</h3>

This project is similar to, and based on, <https://github.com/liamoc/latex-formulae>.
Benefits of rendering LaTeX to images are to

- avoid JavaScript on the client-side and
- allow full LaTeX capabilities (for example, the `tikz` package).

Generating LaTeX images can easily take a few minutes.
Therefore, this project implements a file-based cache.
This is useful for local development and for building via GitHub workflows.

## Demo

My personal website uses this package to generate the LaTeX images. 
For example, see

- https://huijzer.xyz/posts/correlations for some math or
- https://huijzer.xyz/about-site/ for a Tikz picture.

The site's source code is at <https://github.com/rikhuijzer/site>.

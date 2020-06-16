# GenTex

Generate LaTeX images which can be added to Markdown or HTML.
This project is similar to and based on <https://github.com/liamoc/latex-formulae>.
Benefits of rendering LaTeX to images are to

- avoid JavaScript on the client-side, and
- allow full LaTeX capabilities (for example, the `tikz` package).

The project uses manually defined caching since `Memoize.jl` wasn't working.
The benefit of the manual cache is that the cache is available even for fresh Julia instances.

## Demo
This is an example text with <img src="https://huijzer.xyz/latex/12197389782113746666.svg" width="11.2" height="9.6" style="margin:0;vertical-align:-0.0px">, <img src="https://huijzer.xyz/latex/5319274704649611724.svg" width="17.6" height="12.8" style="margin:0;vertical-align:-2.88px">, <img src="https://huijzer.xyz/latex/6852490030217100688.svg" width="17.6" height="16.0" style="margin:0;vertical-align:-0.0px"> and <img src="https://huijzer.xyz/latex/4264404676620526747.svg" width="35.2" height="9.6" style="margin:0;vertical-align:-0.0px">.

<center><img src="https://huijzer.xyz/latex/2495613752529779156.svg" width="86.4" height="41.6"></center>

We could also write <img src="https://huijzer.xyz/latex/3554953603026326203.svg" width="8.0" height="20.8" style="margin:0;vertical-align:-6.621px"> where <img src="https://huijzer.xyz/latex/1793521431819125941.svg" width="124.8" height="20.8" style="margin:0;vertical-align:-4.8px">.

From 'Introduction to Mathematical Statistics':

**Example 1.1.3.** Let <img src="https://huijzer.xyz/latex/12538622003180737024.svg" width="16.0" height="16.0" style="margin:0;vertical-align:-0.0px"> denote the sample space of Example 1.1.2 and let <img src="https://huijzer.xyz/latex/17406682816213213371.svg" width="16.0" height="14.4" style="margin:0;vertical-align:-0.0px"> be the collection of every ordered pair of <img src="https://huijzer.xyz/latex/12538622003180737024.svg" width="16.0" height="16.0" style="margin:0;vertical-align:-0.0px"> for which the sum of the pair is equal to seven. Thus <img src="https://huijzer.xyz/latex/18159528184481867901.svg" width="352.0" height="20.8" style="margin:0;vertical-align:-4.8px">. Suppose that the dice are cast <img src="https://huijzer.xyz/latex/3935298798545812815.svg" width="70.4" height="16.0" style="margin:0;vertical-align:-0.0px"> times and let <img src="https://huijzer.xyz/latex/15637131451191394373.svg" width="9.6" height="19.2" style="margin:0;vertical-align:-3.733px"> denote the frequency of a sum of seven. Suppose that <img src="https://huijzer.xyz/latex/5057383012830839949.svg" width="28.8" height="16.0" style="margin:0;vertical-align:-0.0px"> casts result in <img src="https://huijzer.xyz/latex/10869177412910497149.svg" width="54.4" height="19.2" style="margin:0;vertical-align:-3.733px">. Then the relative frequency with which the outcome was <img src="https://huijzer.xyz/latex/17406682816213213371.svg" width="16.0" height="14.4" style="margin:0;vertical-align:-0.0px"> is <img src="https://huijzer.xyz/latex/15925760637405286524.svg" width="144.0" height="25.6" style="margin:0;vertical-align:-6.621px">. Thus we might associate with <img src="https://huijzer.xyz/latex/17406682816213213371.svg" width="16.0" height="14.4" style="margin:0;vertical-align:-0.0px"> a number <img src="https://huijzer.xyz/latex/16786918996169151623.svg" width="11.2" height="14.4" style="margin:0;verti
cal-align:-3.733px"> that is close to <img src="https://huijzer.xyz/latex/3783830788227099719.svg" width="33.6" height="16.0" style="margin:0;vertical-align:-0.0px">, and <img src="https://huijzer.xyz/latex/16786918996169151623.svg" width="11.2" height="14.4" style="margin:0;vertical-align:-3.733px"> would be called the probability of the event <img src="https://huijzer.xyz/latex/17406682816213213371.svg" width="16.0" height="14.4" style="margin:0;vertical-align:-0.0px">. <img src="https://huijzer.xyz/latex/2189428904744406416.svg" width="14.4" height="14.4" style="margin:0;vertical-align:-0.0px">

And a `Tikz` example:
<center><img src="https://huijzer.xyz/latex/13423659640303949517.svg" width="296.0" height="83.2"></center>

## Usage
Clone the repository to `~.julia/dev` and start the Julia REPL via `julia`.

```
julia> dev GenTex.jl

julia> using GenTex

julia> frompath = <some path to a file with inline equations ($...$) and display equations ($$...$$)>

julia> topath = <some path to where the output file should be>

julia> scale = <scaling factor to apply to the images>

julia> im_dir = <location to store the generated LaTeX images>

julia> substitute_latex!(frompath, topath, scale, im_dir)
File written - 12:52:32
```

## Development
These are some notes which I should move somewhere else.
In Julia it seems to be the idea that you manually start the REPL in combination with Revise.

### Create a new package
To generate a package without PackageTemplates use
```
julia> using Pkg

julia> cd(Pkg.devdir())

pkg> generate MyPkg
Generating project MyPkg:
    MyPkg/Project.toml
    MyPkg/src/MyPkg.jl

pkg> dev MyPkg
```

Then, to use the package with `Revise` use
```
julia> using Revise

julia> using MyPkg
```

### Add package folder to namespace
```
pkg> dev .
```

### Adding a package
To add a package `SomePkg`, make sure to be in the root folder of the project.
Then
```
pkg> activate .

pkg> add SomePkg
```
or 
```
julia> using Pkg; Pkg.activate("SomePkg")

pkg> add SomePkg
```

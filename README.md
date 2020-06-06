# GenerateMarkdown

## Development
In Julia it seems to be the idea that you manually start the REPL in combination with Revise.
It is starting to make sense to me.
You just need to start the REPL once per development session and make sure it keeps running.
Usually you need to focus on certain parts of the codebase anyway.
Therefore, manually running specific commands combined with `entr(...)` makes sense.

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
And to test the package 
```
julia> using Pkg

julia> Pkg.test("MyPkg")
```
Or, in a Revise script
```
entr(() -> Pkg.test("GenerateMarkdown"), [], [GenerateMarkdown])
```
which will only run when a change occurs in the package. 
Not when a change occurs in the test.
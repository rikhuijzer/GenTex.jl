using Documenter
using GenTeX

makedocs(
    sitename = "GenTeX.jl",
    pages = [
        "Home" => "index.md",
    ],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true")
)

deploydocs(repo = "github.com/rikhuijzer/GenTeX.jl.git")

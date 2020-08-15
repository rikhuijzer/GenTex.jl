module GenTeX

# Most time is spend on calling LaTeX, so the compiler shouldn't spend much time on optimizing.
if isdefined(Base, :Experimental) && isdefined(Base.Experimental, Symbol("@optlevel"))
    @eval Base.Experimental.@optlevel 1
end

include("evalmd.jl")
include("cache.jl")
include("example.jl")
include("latex.jl")

end # module

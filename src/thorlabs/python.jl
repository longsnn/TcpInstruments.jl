using Pkg
using PyCall

include("./lts150.jl")

function load_python()
    ENV["PYTHON"] = get(TCP_CONFIG, "python", "")
    Pkg.build("PyCall")
    @info "Python Loaded Please Restart Julia"
    exit()
end


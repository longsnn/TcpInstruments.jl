using Pkg
using PyCall

function load_python()
    ENV["PYTHON"] = get(TCP_CONFIG, "python", "")
    Pkg.build("PyCall")
    @info "Python Loaded Please Restart Julia"
    exit()
end


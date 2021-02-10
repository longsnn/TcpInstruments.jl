using YAML
TCP_CONFIG = nothing

const FILE_LOCATIONS = [
    ".tcp.yml",
    ".tcp.yaml",
    "~/.tcp.yml",
    "~/.tcp.yaml"
]

@info TCP_CONFIG
function init_tcp_yaml()
    global TCP_CONFIG, FILE_LOCATIONS
    file = ""
    for f in FILE_LOCATIONS
        if isfile(f)
            file = f
            break
        end
    end
    if isempty(file)
        @info "No configuration file found:\n$FILE_LOCATIONS"
        return 
    end
    TCP_CONFIG = YAML.load_file(file)
    @info "NEW CONFIG LOADED"
    @info TCP_CONFIG
    for (device, data) in TCP_CONFIG
        device == "Prologix" && continue
        try
            eval(Symbol(device))
        catch e
            error("Device of name: $device inside .tcp.yaml does not exist! For a list of available devices use `help> Instrument`")
        end
    end
end



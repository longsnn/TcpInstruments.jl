using YAML

EXAMPLE_FILE =  "https://raw.githubusercontent.com/Orchard-Ultrasound-Innovation/TcpInstruments.jl/master/.tcp.yml"

TCP_CONFIG = nothing
TCP_FILE = nothing

const FILE_LOCATIONS = [
    joinpath(pwd(), ".tcp.yml"),
    joinpath(homedir(), ".tcp.yml"),
]

function create_config(dir=homedir())
    if Sys.iswindows()
        error("create_config() is not supported on windows yet")
    end
    Base.run(`wget -O $dir/.tcp.yml $EXAMPLE_FILE`)
    load_config()
end

function edit_config()
    @assert TCP_FILE != nothing "No tcp config found! Use `create_config()` to automatically load ours"
    cmd = "$(ENV["EDITOR"]) $(TCP_FILE)"
    if Sys.iswindows()
       Base.run(`cmd /c "$(cmd)"`)
    else
        Base.run(`$(cmd)`)
    end
    load_config()
end

function load_config()
    global TCP_CONFIG, TCP_FILE, FILE_LOCATIONS
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
    TCP_FILE = file
    @info "CONFIG LOADED"
    for (device, data) in TCP_CONFIG
        (device == "Prologix" || device == "python") && continue
        device_type = nothing
        try
            device_type = eval(Symbol(device))
        catch e
            error("Device of name: $device inside .tcp.yaml does not exist! For a list of available devices use `help> Instrument`")
        end
        !(data isa Dict) && continue
        alias = get(data, "alias", "")
        isempty(alias) && continue
        @eval global const $(Symbol(alias)) = $(device_type)
        @eval export $(Symbol(alias)) 
        alias_print("$alias = $device")
    end
end



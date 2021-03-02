module Configuration
using YAML

mutable struct Config
   name::String
   example::String
   file_locations::Array
   config::Union{Dict, Nothing}
   loaded_file::String

   function Config(name; example = "")
       dot = new()
       dot.name = name
       dot.example = example
       dot.file_locations = [joinpath(i, name) for i in [pwd(), homedir()]]
       dot.config = nothing
       dot.loaded_file = ""
       return dot
   end
end

function create_config(config; dir=homedir())
    if Sys.iswindows()
        error("create_config() is not supported on windows yet")
    end
    file_path = joinpath(dir, config.name)
    if isempty(config.example)
        @info """
        No example config specified creating empty config file at:
            $file_path
        """
        Base.run(`touch $file_path`)
    else
        Base.run(`wget -q --show-progress -O $file_path $(config.example)`)
    end
    load_config(config)
end

function edit_config(config)
    @assert config.config != nothing """
    No config loaded.
    Cannot edit a config file that doesn't exists.

    Create a new empty config from your shell by running:
        touch $(config.name)

    Or

    To load the latest config use the create_config function
    """
    editor, file = ENV["EDITOR"], config.loaded_file
    if Sys.iswindows()
        Base.run(`powershell "$editor $file"`)
    else
        Base.run(`$editor $file`)
    end
    load_config(config)
end

function load_config(config)
    for f in config.file_locations
        if isfile(f)
            config.loaded_file = f
            break
        end
    end
    if isempty(config.loaded_file)
        config.config = Dict()
        @info "No configuration file found:\n$(config.file_locations)"
        return
    end
    try
        config.config = YAML.load_file(config.loaded_file)
        @info "$(config.loaded_file) ~ loaded"
    catch
        @info "$(config.loaded_file) is empty"
        config.config = Dict()
    end
end

function get_config(config)
    if config.config == nothing
        load_config(config)
        return config.config
    end
    return config.config
end

end # Configuration

const EXAMPLE_FILE = "https://raw.githubusercontent.com/Orchard-Ultrasound-Innovation/TcpInstruments.jl/master/.tcp_instruments.yml" 

const tcp_config = Configuration.Config(
    ".tcp_instruments.yml"; 
    example = EXAMPLE_FILE
)

function get_config()
    return Configuration.get_config(tcp_config)
end

function create_config(;dir=homedir())
    Configuration.create_config(tcp_config; dir=dir)
end

function edit_config()
    Configuration.edit_config(tcp_config)
end

function load_config()
    Configuration.load_config(tcp_config)
    isempty(tcp_config.loaded_file) && return
    create_aliases(tcp_config)
end

function create_aliases(config)
    for (device, data) in config.config
        device == "python" && continue
        device_type = nothing
        try
            device_type = eval(Symbol(device))
        catch e
            error("""
            $(config.loaded_file) contains device of name:
                $device
            
            This is not a valid device.

            For a list of available devices use `help> Instrument`
            """)
        end
        !(data isa Dict) && continue
        alias = get(data, "alias", "")
        isempty(alias) && continue
        @eval global const $(Symbol(alias)) = $(device_type)
        @eval export $(Symbol(alias)) 
        alias_print("$alias = $device")
    end
end

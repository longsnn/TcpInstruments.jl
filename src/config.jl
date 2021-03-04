using InstrumentConfig

const EXAMPLE_FILE = "https://raw.githubusercontent.com/Orchard-Ultrasound-Innovation/TcpInstruments.jl/master/.tcp_instruments.yml" 

const tcp_config = InstrumentConfig.Config(
    ".tcp_instruments.yml"; 
    example = EXAMPLE_FILE
)

function get_config()
    return InstrumentConfig.get_config(tcp_config)
end

function create_config(;dir=homedir())
    InstrumentConfig.create_config(tcp_config; dir=dir)
end

function edit_config()
    InstrumentConfig.edit_config(tcp_config)
end

function load_config()
    InstrumentConfig.load_config(tcp_config)
    create_aliases(tcp_config)
end

function create_aliases(config; ignore=[])
    for (device, data) in config.config
        if device in ignore
            continue
        end
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

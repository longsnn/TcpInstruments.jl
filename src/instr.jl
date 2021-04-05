"""
An instrument is a generic device with which you can take and read measurements

All instruments can be initialized and terminated. For more
information on how to connect to a supported instrument:
```
help>initialize
```

You can use the help feature on any supported instrument group.

For more information on the actual instruments you can initialize use julia's help feature on one of the supported instrument groups.

For example lets say you want to learn about oscilloscopes.
```
julia>?
help>Oscilloscope

  Supported Instruments:
  ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡

    •  AgilentDSOX4034A
```

Pick one of the supported instruments for more information on
how to use it and for all its available functions:
```
help>AgilentDSOX4034A
```


# Supported Instrument Groups
- `Oscilloscope`
- `MultiMeter`
- `PowerSupply`
- `WaveformGenerator`
- `ImpedanceAnalyzer`
- `XYZStage`


"""
abstract type Instrument end
"""
# Supported Instruments
- [`AgilentDSOX4024A`](@ref)
- `AgilentDSOX4034A`
"""
abstract type Oscilloscope <: Instrument end

"""
# Supported Instruments
- KeysightDMM34465A
"""
abstract type MultiMeter <: Instrument end

"""
# Supported Instruments
- `AgilentE36312A`
- `VersatilePower`
- `PS310`
"""
abstract type PowerSupply <: Instrument end


# Maybe store ips in a config file and it dynamically shows you address?
"""
# Supported Instruments:
- `Keysight33612A`: Default ip ~ "10.1.30.36"
"""
abstract type WaveformGenerator <: Instrument end

"""
# Supported Instruments:
- `Agilent4294A`
- `Agilent4395A`

"""
abstract type ImpedanceAnalyzer <: Instrument end

mutable struct Instr{ T <: Instrument } <: Instrument
    model::Union{Type, T}
    address::String
    sock::TCPSocket
    connected::Bool
end

function CreateTcpInstr(model, address)
    Instr{model}(model, address, TCPSocket(), false)
end

function Base.show(io::IO, ::MIME"text/plain", i::TcpInstruments.Instr)
    model = i.model isa DataType ? i.model : typeof(i.model)
    println("TcpInstruments.Instr{$(i.model)}")
    println("    Group: $(supertype(model))")
    println("    Model: $(model)")
    println("    Address: $(i.address)")
    println("    Connected: $(i.connected)")
end

"""
    initialize(model, address)

Initializes a connection to the instrument at the given (input) IP address.

# Arguments
- `model`: They device type you are connecting to. Use `help> -->Instrument` to see available options.
- `address::String`: The ip address of the device. Ex. "10.3.30.23"

# Keywords
- `GPIB_ID::Int`: The GPIB interface ID of your device. This is optional and doesn't need to be set unless you are using a prologix controller to control it remotely. 
"""
function initialize(model::Type{T}, address; GPIB_ID=-1) where T <: Instrument
    instr_h = CreateTcpInstr(model, address)
    connect!(instr_h)
    remote_mode(instr_h)
    if GPIB_ID >= 0
        set_prologix_chan(instr_h, GPIB_ID)
    end
    return instr_h
end

function initialize(model::Type{T}) where T <: Instrument
    data = nothing
    try
        data = get_config()[string(model)]
    catch e
        error("""
        $(string(model)) was not found in your .tcp_instruments.yml file.
        To update to the latest version:
        `create_config()`

        Otherwise please add it to your config file or
        specify an ip address:
        `initialize($(string(model)), "10.1.30.XX")`
        
        """)
    end
    if data isa String
        return initialize(model, data)
    end

    address = get(data, "address", "")
    gpib = get(data, "gpib", "")

    if isempty(gpib)
        return initialize(model, address)
    end
    return initialize(model, address, GPIB_ID=gpib)
end

"""
    terminate(instr)

Closes the TCP connection.
"""
function terminate(instr::Instrument)
    close!(instr)
    local_mode(instr)
end

reset(obj) = write(obj, "*RST")

remote_mode(obj)   = nothing
local_mode(obj) = nothing
set_prologix_chan(obj, chan) = write(obj, "++addr $chan")
get_prologix_chan(obj) = query(obj, "++addr")
"""
    info(instr_h)
Asks an instrument to print model number and other device info.
"""
info(obj) = query(obj, "*IDN?")


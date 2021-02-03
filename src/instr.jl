
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

"""
abstract type Instrument end

"""
# Supported Instruments
- `AgilentDSOX4034A`
"""
abstract type Oscilloscope <: Instrument end

"""
# Supported Instruments
- I am lonely
"""
abstract type MultiMeter <: Instrument end

"""
# Supported Instruments
- `BenchXR`
- `AgilentE36312A`
"""
abstract type PowerSupply <: Instrument end


# Maybe store ips in a config file and it dynamically shows you address?
"""
# Supported Instruments:
- `Keysight33612A`: Default ip ~ "10.1.30.36"
"""
abstract type WaveformGenerator <: Instrument end

mutable struct Instr{ T <: Instrument } <: Instrument
    model::Type
    address::String
    buffer_size::Int
    sock::TCPSocket
    connected::Bool
    id_str::String
end

function CreateTcpInstr(model, address)
    Instr{model}(
        model, 
        address, 
        1024, 
        TCPSocket(), 
        false, 
        "empty-ID"
    )
end

"""
    initialize(model, address)

Initializes a connection to the instrument at the given (input) IP address.

# Arguments
- `model`: They device type you are connecting to. Use `help>Instrument` to see available options.
- `address::String`: The ip address of the device. Ex. "10.3.30.23"
"""
function initialize(model, address)
    instr_h = CreateTcpInstr(model, address)
    connect!(instr_h)
    lock!(instr_h)
    return instr_h
end


"""
    terminate(instr)

Closes the TCP connection.
"""
function terminate(instr::Instrument)
    close!(instr)
    unlock!(instr)
end

reset!(obj) = write(obj, "*RST")

lock!(obj)   = nothing
unlock!(obj) = nothing


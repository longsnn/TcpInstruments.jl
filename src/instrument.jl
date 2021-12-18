import InstrumentConfig: initialize, terminate

"""
An instrument is a generic device with which you can take and read measurements

All instruments can be initialized and terminated. For more
information on how to connect to a supported instrument:
```
help> initialize
```

You can use the help feature on any supported instrument group.

For more information on the actual instruments you can initialize use julia's help feature on one of the supported instrument groups.

For example lets say you want to learn about oscilloscopes.
```
julia> ?
help> Oscilloscope

  Supported Instruments:
  ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡

    •  AgilentDSOX4034A
```

Pick one of the supported instruments for more information on
how to use it and for all its available functions:
```
help> AgilentDSOX4034A
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
- [`KeysightDMM34465A`](@ref)
"""
abstract type MultiMeter <: Instrument end


"""
- [`AgilentE36312A`](@ref)
- [`SRSPS310`](@ref)
- [`VersatilePower`](@ref)
"""
abstract type PowerSupply <: Instrument end


# Maybe store ips in a config file and it dynamically shows you address?
"""
- [`Keysight33612A`](@ref)
"""
abstract type WaveformGenerator <: Instrument end


"""
- [`Agilent4294A`](@ref)
- [`Agilent4395A`](@ref)
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
    initialize(model::Type{Instrument})
    initialize(model::Type{Instrument}, address::String; GPIB_ID::Int=-1)

Initializes a connection to the instrument at the given (input) IP address.

# Arguments
- `model`: The device type you are connecting to. Use `help> Instrument` to see available options
- `address` (optional): The ip address of the device. Ex. "10.3.30.23". If not provided, TcpInstruments will look for the address in the config file

# Keywords
- `GPIB_ID`: The GPIB interface ID of your device. This is optional and doesn't need to be set unless you are using a prologix controller to control it remotely
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

    # TODO: refactor the following using traits
    if data isa String
        instr_h = initialize(model, data)
    else
        address = get(data, "address", "")
        gpib = get(data, "gpib", "")
        if isempty(gpib)
            instr_h = initialize(model, address)
        else
            instr_h = initialize(model, address, GPIB_ID=gpib)
        end
    end

    return instr_h
end


"""
    terminate(instr::Instrument)

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
    info(instr::Instrument)

Asks an instrument to print model number and other device info.
"""
info(obj) = query(obj, "*IDN?")


import Base.write, Base.read


function connect!(instr::Instrument)
    instr.connected && error("Cannot connect. Instrument is already connected!")
	SCPI_port = 5025
	host,port = split_str_into_host_and_port(instr.address)
	port == 0 && (port = SCPI_port)
	instr.sock = connect(host,port)
	instr.connected = true
end

function close!(instr::Instrument)::Bool
    !instr.connected && error("Cannot disconnect. Instrument is not connected!")
	close(instr.sock)
	instr.connected = false
end

function write(instr::Instrument, message::AbstractString)
    !instr.connected && error("Instrument is not connected, cannot write to it!")
	println(instr.sock, message)
end

function read(instr::Instrument)
    !instr.connected && error("Instrument is not connected, cannot read from it!")
	return rstrip(readline(instr.sock), ['\r', '\n'])
end

"""
Writes a message to a device then listens for and returns any output from
the device.

This is a blocking procedure and will block until a response is received from the device or
till it has been blocking for longer than the designated `timeout` time after which an
error will be thrown.

# Arguments
- `instr::Instrument`: Any instrument that supports being written to and read from
- `message::AbstractString`: The message to be sent to the device before listening for a response
- `timeout`: _Optional flag_ ~ How long to try and listen for a response before giving up and throwing an error. The default time is 2.8 seconds. _Note_: if timeout is set to 0 then this will turn off the timeout functionality and `query` may listen/block indefinitely for a response
"""
function query(instr::Instrument, message::AbstractString; timeout=2.8)
    write(instr, message)
    if timeout == 0
        return read(instr)
    end
    proc = @spawn read(instr)
    start_clock = time()
    while (time() - start_clock) < timeout
        if proc.state != :runnable
            break
        end
        sleep(0.05)
    end
    if proc.state == :runnable
        schedule(proc, ErrorException("Query timed out"), error=true)
        error("Query timed out")
    end
    return fetch(proc)
end

"""
Differs from [query](@ref) in that it will return a Float64 and not a String
"""
f_query(obj, ins; timeout=0.5) = parse(Float64, query(obj, ins; timeout=timeout))

"""
Differs from [query](@ref) in that it will return an Int64 and not a String
"""
i_query(obj, ins; timeout=0.5) = parse(Int64, query(obj, ins; timeout=timeout))

using Base.Threads: @spawn
using Sockets
using Dates
using MAT
using JLD2

import Base.write, Base.read


function connect!(instr::Instrument)
	@assert !instr.connected "Cannot connect. Instrument is already connected!"
	SCPI_port = 5025
	host,port = split_str_into_host_and_port(instr.address)
	port == 0 && (port = SCPI_port)
	instr.sock = connect(host,port)
	instr.connected = true
end

function close!(instr::Instrument)::Bool
	@assert instr.connected "Cannot disconnect. Instrument is not connected!"
	close(instr.sock)
	instr.connected = false
end

function write(instr::Instrument, message::AbstractString)
	@assert instr.connected "Instrument is not connected, cannot write to it!"
	println(instr.sock, message)
end

# TODO: Have a timeout parameter
function read(instr::Instrument; timeout=5)
	@assert instr.connected "Instrument is not connected, cannot read from it!"
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
- `timeout`: _Optional flag_ ~ How long to try and listen for a response before giving up and throwing an error. The default time is half a second. _Note_: if timeout is set to 0 then this will turn off the timeout functionality and `query` may listen/block indefinitely for a response
"""
function query(instr::Instrument, message::AbstractString; timeout=1.8)
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

"""
    save(data)
    save(data; format=:matlab)
    save(data; filename="custom_file_name.ext")

Save data to a file

By default saves to julia format (.jld2) but can also export
data to matlab by using the format=:matlab keyword argument
"""
function save(data; filename="", format=:julia)
    if isempty(filename)
        t = Dates.format(Dates.now(), "yy-mm-dd_HH:MM:SS")
        filename = "scan_" * t
    end
    if format == :julia
        @save (filename * ".jld2") data
    elseif format == :matlab
        file = matopen(filename * ".mat", "w")
        write(file, "data", data)
        close(file)
    end
end

"""
    data = load("file.jld2")

Loads saved data from a file
"""
function load(filename)
    ext = split(filename, '.')[end]
    if ext == "jld2"
        jldopen(filename)["data"]
    else
        error("unsupported file type: $ext")
    end
end

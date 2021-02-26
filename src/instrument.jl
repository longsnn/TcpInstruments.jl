using Base.Threads: @spawn
using Sockets

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
function query(instr::Instrument, message::AbstractString; timeout=1.4)
    write(instr, message)
    if timeout == 0
        return read(instr)
    end
    proc = @spawn read(instr)
    sleep(timeout)
    if proc.state == :runnable
        schedule(proc, ErrorException("Query timed out"), error=true)
        error("Query timed out")
    end
    return fetch(proc)
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

Differs from query in that it will return a Float64 and not a String
"""
f_query(obj, ins; timeout=0.5) = parse(Float64, query(obj, ins; timeout=timeout))

# Generic instrument struct
abstract type Instrument end
abstract type Oscilloscope <: Instrument end
abstract type MultiMeter <: Instrument end
abstract type PowerSupply <: Instrument end
abstract type WaveformGenerator <: Instrument end

using Sockets
import Base.write, Base.read

mutable struct GenericInstrument <: Instrument
    name::Symbol
    address::String
	buffer_size::Int
    sock::TCPSocket
	connected::Bool
	id_str::String
end
# Generic instrument constructor
GenericInstrument(instr_name, address) = GenericInstrument(instr_name, address, 1024, TCPSocket(), false, "empty-ID")

function connect!(instr::Instrument)
	@assert !instr.connected "Cannot connect. Instrument is already connected!"
	SCPI_port = 5025
	host,port = split_str_into_host_and_port(instr.address)
	isempty(port) && (port = SCPI_port)
	instr.sock = connect(host,port)
	instr.connected = true;
end

function disconnect!(instr::Instrument)
	@assert instr.connected "Cannot disconnect. Instrument is not connected!"
	close(instr.sock)
	instr.connected = false;
end

"""
	split_str_into_host_and_port(str)
Splits a string like "192.168.1.1:5056" into ("192.168.1.1", 5056)
"""
function split_str_into_host_and_port(str) 
	spl_str = split(str, ":")
	@assert !isempty(spl_str) "IP address string is empty!"
	host = spl_str[1]
	if length(spl_str) == 1
		port = []
	else
		port = parse(Int, split_str[2])
	end
	return (host, port)
end

function write(instr::Instrument, message::AbstractString)
	@assert instr.connected "Instrument is not connected, cannot write to it!"
	println(instr.sock, message)
end

# TODO: Have a timeout parameter
function read(instr::Instrument)
	@assert instr.connected "Instrument is not connected, cannot read from it!"
	return rstrip(readline(instr.sock), ['\r', '\n'])
end

function query(instr::Instrument, message::AbstractString)
	write(instr, message)
	return read(instr)
end

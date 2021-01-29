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



""" Initializes a connection to the instrument at the given (input) IP address."""
function initialize(model, address)
    instr_h = CreateTcpInstr(model, address)
    connect!(instr_h)
    return instr_h
end

""" Closes the TCP connection."""
terminate(instr::Instrument) = close!(instr)


function connect!(instr::Instrument)
	@assert !instr.connected "Cannot connect. Instrument is already connected!"
	SCPI_port = 5025
	host,port = split_str_into_host_and_port(instr.address)
	port == 0 && (port = SCPI_port)
	instr.sock = connect(host,port)
	instr.connected = true;
end

function close!(instr::Instrument)::Bool
	@assert instr.connected "Cannot disconnect. Instrument is not connected!"
	close(instr.sock)
	instr.connected = false;
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

function query(instr::Instrument, message::AbstractString)
	write(instr, message)
	return read(instr)
end

"""
	split_str_into_host_and_port(str)
Splits a string like "192.168.1.1:5056" into ("192.168.1.1", 5056)
"""
function split_str_into_host_and_port(str::AbstractString)::Tuple{String, Int}
	spl_str = split(str, ":")
	@assert !isempty(spl_str) "IP address string is empty!"
	host = spl_str[1]
	if length(spl_str) == 1
		port = 0
	else
		port = parse(Int, spl_str[2])
	end
	return (host, port)
end

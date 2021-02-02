# Generic instrument struct
abstract type Instrument end
abstract type Oscilloscope <: Instrument end
abstract type MultiMeter <: Instrument end
abstract type PowerSupply <: Instrument end
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
    Instr{model}(model, address, 1024, TCPSocket(), false, "empty-ID")
end


reset!(obj) = write(obj, "*RST")

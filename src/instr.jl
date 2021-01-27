using Sockets
# Generic instrument struct
abstract type Instrument end
abstract type Oscilloscope <: Instrument end
abstract type MultiMeter <: Instrument end
abstract type PowerSupply <: Instrument end
abstract type WaveformGenerator <: Instrument end



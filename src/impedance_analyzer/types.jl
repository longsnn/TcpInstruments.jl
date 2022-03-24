"""
- [`Agilent4294A`](@ref)
- [`Agilent4395A`](@ref)
"""
abstract type ImpedanceAnalyzer <: Instrument end


"""
http://literature.cdn.keysight.com/litweb/pdf/04294-90061.pdf
# Available functions
- `initialize()`
- `terminate()`
- [`get_impedance`](@ref)
- [`get_bandwidth`](@ref)
- [`set_bandwidth`](@ref)
- [`get_volt_ac`](@ref)
- [`set_volt_ac`](@ref)
- [`get_channel`](@ref)
- [`set_channel`](@ref)
"""
struct Agilent4294A <: ImpedanceAnalyzer end


"""
http://literature.cdn.keysight.com/litweb/pdf/04395-90031.pdf
# Available functions
- `initialize()`
- `terminate()`
- `get_frequency_range()`
- `set_frequency_range([start, stop]) # in hertz)
- `get_num_data_points(x)`
    - number of points on x-axis / number of samples
- `set_num_data_points(x)`
- `get_impedance()` # get the data
- `set_volt_ac`
- `get_volt_ac`
- `get_volt_dc`
- `set_volt_dc`
- `bandwidth ({1,2,3,4,5})`
    - 1 -> lowest bandwidth, 35 -> highest bandwidth
"""
struct Agilent4395A <: ImpedanceAnalyzer end

struct ImpedanceAnalyzerInfo
    dc_voltage::Unitful.Voltage
    ac_voltage::Unitful.Voltage
    num_averages::Int64
    bandwidth_level::Int64
    point_delay_time::Unitful.Time
    sweep_delay_time::Unitful.Time
    sweep_direction::String
end

struct ImpedanceAnalyzerData
    info::Union{ImpedanceAnalyzerInfo, Nothing}
    frequency::Vector{typeof(1.0u"Hz")}
    impedance::Vector{typeof((1.0+1.0im)*u"Ω")}
end

function Base.show(io::IO, data::ImpedanceAnalyzerData)
    show(data.info)
    println(io, "frequency: ", size(data.frequency), " ", unit(data.frequency[1]))
    println(io, "impedance: ", size(data.impedance), " ", unit(data.impedance[1]))
end

function Base.show(io::IO, info::ImpedanceAnalyzerInfo)
    println(io, "ImpedanceAnalyzerInfo: ")
    for fieldname in fieldnames(typeof(info))
        println(io, "  " * String(fieldname) * ": ", getfield(info, fieldname))
    end
end

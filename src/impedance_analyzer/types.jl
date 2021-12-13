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

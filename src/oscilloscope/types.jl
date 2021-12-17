"""
- [`AgilentDSOX4024A`](@ref)
- [`AgilentDSOX4034A`](@ref)
"""
abstract type Oscilloscope <: Instrument end

abstract type AgilentScope <: Oscilloscope end
struct AgilentDSOX4024A <: AgilentScope end
struct AgilentDSOX4034A <: AgilentScope end

struct ScopeInfo
    format::String
    type::String
    num_points::Int64
    x_increment::Float64
    x_origin::Float64
    x_reference::Float64
    y_increment::Float64
    y_origin::Float64
    y_reference::Float64
    impedance::String
    coupling::String
    low_pass_filter::String
    channel::Int64
end

struct ScopeData
    info::Union{ScopeInfo, Nothing}
    volt::Vector{typeof(1.0u"V")}
    time::Vector{typeof(1.0u"s")}
end

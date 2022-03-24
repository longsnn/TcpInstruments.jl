"""
- [`AgilentScope`](@ref)
"""
abstract type Oscilloscope <: Instrument end


"""
Supported models
- `AgilentDSOX4024A`
- `AgilentDSOX4034A`

Supported functions
- [`initialize`](@ref)
- [`terminate`](@ref)


- [`run`](@ref)
- [`stop`](@ref)
- [`get_data`](@ref)
- [`get_waveform_info`](@ref)


- [`get_impedance`](@ref)
- [`set_impedance_1Mohm`](@ref)
- [`set_impedance_50ohm`](@ref)
- [`get_lpf_state`](@ref)
- [`lpf_on`](@ref)
- [`lpf_off`](@ref)
- [`get_coupling`](@ref)
"""
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

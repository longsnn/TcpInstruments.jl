Base.@kwdef struct FakeDSOX4034A <: Oscilloscope
    num_samples = 65104
end

function initialize(model::Type{FakeDSOX4034A})
    return Instr{model}(model(), "", TCPSocket(), true)
end

function initialize(model::FakeDSOX4034A)
    return Instr{typeof(model)}(model, "", TCPSocket(), true)
end

function get_data(instr::Instr{FakeDSOX4034A}, ch::Vector{Int}) 
    for num in ch
        if num < 1 || num > 4
            error("$num is not a valid channel")
        end
    end
    map(c->get_data(instr, c), ch)
end

num_samples(i::Instr{FakeDSOX4034A}) = i.model.num_samples


function get_data(instr::Instr{FakeDSOX4034A}, ch::Int; scope_stats=false)
    info = get_default_scope_info(instr, ch)
    samples = info.num_points

    volt = if ch == 1
            map(sin, collect(range(0, stop=6pi, length=samples))) .* V
        elseif ch == 2
            map(cos, collect(range(0, stop=6pi, length=samples))) .* V
        elseif ch == 3
            map(x->abs(sin(x)) / -3, collect(range(0, stop=16pi, length=samples))) .* V
        else
            map(x->abs(sin(x)) / 3, collect(range(0, stop=16pi, length=samples))) .* V
    end
    time = collect(range(-0.0025, stop=0.0025, length=samples)) * s
    return ScopeData(info, volt, time)
end


function get_default_scope_info(scope::Instr{FakeDSOX4034A}, channel::Int)
    format = "8bit"
    type = "Normal"
    num_points = num_samples(scope)
    x_increment = 7.68e-8
    x_origin = -0.0025
    x_reference = 0.0
    y_increment = 0.0167364
    y_origin = 1.28425
    y_reference = 128.0
    impedance = ""
    coupling = ""
    low_pass_filter = ""
    return ScopeInfo(format, type, num_points, 
                     x_increment, x_origin, x_reference,
                     y_increment, y_origin, y_reference, 
                     impedance, coupling, low_pass_filter, channel)
end


function scope_waveform_info_get(scope::Instr{FakeDSOX4034A}, channel::Int)
    return get_default_scope_info(scope, channel)
end

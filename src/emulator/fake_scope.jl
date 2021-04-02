import InstrumentConfig: initialize, terminate

Base.@kwdef struct FakeDSOX4034A
    num_samples = 65104
end

function initialize(::Type(FakeDSOX4034A))
    return FakeDSOX4034A()
end

function get_data(instr::FakeDSOX4034A, ch::Vector{Int}) 
    for num in ch
        if num < 1 || num > 4
            error("$num is not a valid channel")
        end
    end
    map(c->get_data(instr, c), ch)
end


function get_data(instr::FakeDSOX4034A, ch::Int; scope_stats=false)
    # TODO: Replace with actual fake raw data. raw_data = scope_read_raw_waveform(instr);
    # return scope_parse_raw_waveform(raw_data, wfm_info) 

    info = ScopeInfo(
        "8bit", 
        "Normal", 
        instr.num_samples,
        7.68e-8, 
        -0.0025, 
        0.0, 
        0.0167364, 
        1.28425, 
        128.0, 
        "", 
        "", 
        "", 
        ch
    )

    volt = if ch == 1
            map(sin, collect(range(0, stop=6pi, length=instr.num_samples))) .* V
        elseif ch == 2
            map(cos, collect(range(0, stop=6pi, length=instr.num_samples))) .* V
        elseif ch == 3
            map(x->abs(sin(x)) / -3, collect(range(0, stop=16pi, length=instr.num_samples))) .* V
        else
            map(x->abs(sin(x)) / 3, collect(range(0, stop=16pi, length=instr.num_samples))) .* V
    end
    time = collect(range(-0.0025, stop=0.0025, length=instr.num_samples))
    return ScopeData(info, volt, time)
end


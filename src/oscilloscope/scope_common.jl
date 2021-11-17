using RecipesBase

const RESOLUTION_MODE = Dict("+0" => "8bit", "+1" => "16bit", "+2" => "ASCII")
const TYPE = Dict("+0" => "Normal", "+1" => "Peak", "+2" => "Average",  "+3" => "High Resolution")

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


@recipe function plot(data::ScopeData; label="", xguide="0", yguide="Voltage / V")
    scaled_time, volts, t, l, x, y= plot_helper(data; label=label, xguide=xguide, yguide=yguide)
    title := t
    label := l
    xguide := x
    yguide := y
    return scaled_time, volts
end


@recipe function plot(data_array::Array{ScopeData, 1}; label="", xguide="0", yguide="Voltage / V")
    for data in data_array
        @series begin
            scaled_time, volts, t, l, x, y= plot_helper(data; label=label, xguide=xguide, yguide=yguide)
            title := t
            label := l
            xguide := x
            yguide := y
            return scaled_time, volts
        end
    end
end


status(obj, chan) = query(obj, "STAT? CHAN$chan") == "1" ? true : false


function plot_helper(data::ScopeData; label="", xguide="0", yguide="Voltage / V")
    time_unit, scaled_time = autoscale_seconds(data.time)
    title = "Oscilloscope ~ Voltage Vs. Time (" * time_unit * ")"
    if isempty(label)
        label = "Channel $(data.info.channel)"
    else
        label = label
    end
    if xguide == "0"
        xguide = "Time / " * time_unit
    else
        xguide = xguide
    end
    return ustrip(scaled_time), ustrip(data.volt), title, label, xguide, yguide
end


function autoscale_seconds(time_data)
    unit = "seconds"
    time_array = time_data
    m = abs(min(time_data...))
    m = ustrip(m)

    if m >= 1
    elseif 1 > m && m >= 1e-3
        unit = "ms" # miliseconds
        time_array = ms.(time_data)
    elseif 1e-3 > m && m >= 1e-6
        unit = "μs" # microseconds
        time_array = μs.(time_data)
    elseif 1e-6 > m && m >= 1e-9
        unit = "ns" # nanoseconds
        time_array = ns.(time_data)
    else
        unit = "ps" # picoseconds
        time_array = ps.(time_data)
    end
    return unit, time_array
end


"""
    get_coupling(scope, chan=1)

returns "AC" or "DC"
"""
get_coupling(instr::Instrument; chan=1) = query(instr, "CHANNEL$chan:COUPLING?")


"""
    lpf_on(scope, chan=1)

Turn on an internal low-pass filter. When the filter is on, the bandwidth of
the specified channel is limited to approximately 25 MHz.
"""
lpf_on(instr::Instrument, chan=1) = write(instr, "CHANNEL$chan:BWLIMIT ON")


"""
    lpf_off(scope, chan=1)

Turn off an internal low-pass filter.
"""
lpf_off(instr::Instrument, chan=1) = write(instr, "CHANNEL$chan:BWLIMIT OFF")


"""
    get_lpf_state(scope, chan=1)

See state the internal low-pass filter:

returns "0" or "1"
"""
get_lpf_state(instr::Instrument; chan=1) = query(instr, "CHANNEL$chan:BWLIMIT?")


"""
    set_impedance_1Mohm(scope, chan=1)

Set impedance to 1MΩ
"""
set_impedance_1Mohm(instr::Instrument; chan=1) = write(instr, ":CHANNEL$chan:IMPEDANCE ONEMEG")


"""
    set_impedance_50ohm(scope)
    set_impedance_50ohm(scope, chan=2)

# Keywords
- `chan`: Specify channel: Default is 1

Set impedance to 50Ω
"""
set_impedance_50ohm(instr::Instrument; chan=1) = write(instr, ":CHANNEL$chan:IMPEDANCE FIFTY")


"""
    get_impedance(scope)
    set_impedance(scope, chan=2)

# Keywords
- `chan`: Specify channel: Default is 1

# Returns
- `"FIFT"`: 50Ω
- `"ONEM"`: 1MΩ
"""
get_impedance(instr::Instrument; chan::Integer=1) = query(instr, ":CHANNEL$chan:IMPEDANCE?")


"""
    run(scope)

Run Oscilloscope
"""
run(obj::Instr{T}) where T <: Oscilloscope = write(obj, "RUN")


"""
    stop(scope)
    
Stop Oscilloscope
"""
stop(obj::Instr{T}) where T <: Oscilloscope = write(obj, "STOP")


scope_waveform_preamble_get(instr) = query(instr, "WAVEFORM:PREAMBLE?")
scope_waveform_source_set(instr, ch::Int) = write(instr, "WAVEFORM:SOURCE CHAN$ch")
scope_waveform_source_get(instr) = query(instr, "WAVEFORM:SOURCE?")
scope_waveform_mode_8bit(instr::Instrument) = write(instr, "WAVEFORM:FORMAT BYTE")
scope_waveform_mode_16bit(instr::Instrument) = write(instr, "WAVEFORM:FORMAT WORD")
scope_waveform_num_points(instr::Instrument, num_points::Integer) = write(instr, "WAVEFORM:POINTS $num_points")
scope_waveform_num_points(instr::Instrument, mode::String) = write(instr, "WAVEFORM:POINTS $mode")
scope_waveform_points_mode(instr::Instrument, mode_idx::Integer) = write(instr, "WAVEFORM:POINTS:MODE $(WAVEFORM_POINTS_MODE[mode_idx])") #norm, max, raw
const WAVEFORM_POINTS_MODE = Dict(0=>"norm", 1=>"max")


function scope_speed_mode(instr::Instrument, speed::Integer)
    if speed == 1
        scope_waveform_mode_16bit(instr)
        scope_waveform_points_mode(instr, 1)
    elseif speed == 3
        scope_waveform_mode_16bit(instr)
        scope_waveform_points_mode(instr, 0)
    elseif speed == 5
        scope_waveform_mode_8bit(instr)
        scope_waveform_points_mode(instr, 1)
    elseif speed == 6
        scope_waveform_mode_8bit(instr)
        scope_waveform_points_mode(instr, 0)
    end
end


function get_data(
    instr::Instrument, ch_vec::Union{Vector{Int}, Nothing} = nothing;
    inbounds=false, scope_stats=false
)
    if ch_vec === nothing || !inbounds
        statuses = asyncmap(x->(x, status(instr, x)), 1:4)
        filter!(x -> x[2], statuses)
        valid_channels = map(x -> x[begin], statuses)
    end
    if ch_vec === nothing
        ch_vec = valid_channels
        !inbounds && @info "Loading channels: $ch_vec"
    else
        unique!(ch_vec)
        if !inbounds
            for ch in ch_vec
                if !(ch in valid_channels)
                    error("Channel $ch is offline, data cannot be read")
                end
            end
        end
    end
    stop(instr) # Makes sure the data from each channel is from the same trigger event
    wfm_data = [get_data(instr, ch; scope_stats=scope_stats) for ch in ch_vec]
    run(instr)
    return wfm_data
end


function get_data(instr::Instrument, ch::Integer; scope_stats=false)
    scope_waveform_source_set(instr, ch)
    wfm_info = scope_waveform_info_get(instr, ch; scope_stats=scope_stats)
    raw_data = scope_read_raw_waveform(instr);
    return scope_parse_raw_waveform(raw_data, wfm_info)
end


function scope_waveform_info_get(instr::Instrument, ch::Integer; scope_stats=false)
    str = scope_waveform_preamble_get(instr)
    str_array = split(str, ",")
    format      = RESOLUTION_MODE[str_array[1]]
    type        = TYPE[str_array[2]]
    num_points  = parse(Int64,   str_array[3])
    count       = parse(Int64,   str_array[4]) # is always one
    x_increment = parse(Float64, str_array[5])
    x_origin    = parse(Float64, str_array[6])
    x_reference = parse(Float64, str_array[7])
    y_increment = parse(Float64, str_array[8])
    y_origin    = parse(Float64, str_array[9])
    y_reference = parse(Float64, str_array[10])
    if scope_stats
        imp = get_impedance(instr; chan=ch)
        coupling =  get_coupling(instr; chan=ch)
        low_pass_filter =  get_lpf_state(instr; chan=ch)
    else
        imp = ""
        coupling = ""
        low_pass_filter = ""
    end
    return ScopeInfo(format, type, num_points, x_increment, x_origin, x_reference, y_increment, y_origin, y_reference, imp, coupling, low_pass_filter, ch)
end


function scope_read_raw_waveform(instr::Instrument, ch; scope_stats=0)
    scope_read_raw_waveform(instr)
end

function scope_read_raw_waveform(instr::Instrument)
    write(instr, "WAV:DATA?")
    num_waveform_samples = get_num_waveform_samples(instr)
    raw_data = read(instr.sock, num_waveform_samples);
    # read end of line character
    dummy = readline(instr.sock)
    return raw_data
end


function get_num_waveform_samples(instr::Instrument)
    header = get_data_header(instr)
    num_header_description_bytes = 2
    num_waveform_samples = parse(Int, header[num_header_description_bytes+1:end])
    return num_waveform_samples
end


function get_data_header(instr::Instrument)
    # data header is an ASCII character string "#8DDDDDDDD", where the Ds indicate how many
    # bytes follow (p.1433 of Keysight InfiniiVision 4000 X-Series Oscilloscopes
    # Programmer's Guide)
    num_header_description_bytes = 2
    header_description_uint8 = read(instr.sock, num_header_description_bytes)
    if header_description_uint8[1] != UInt8('#')
        error("The waveform data format is not formatted as expected")
    end
    header_block_length = parse(Int, convert(Char, header_description_uint8[2]))
    header_block_uint8 = read(instr.sock, header_block_length)
    header = vcat(header_description_uint8, header_block_uint8)
    header = String(convert.(Char, header))
    return header
end


function scope_parse_raw_waveform(wfm_data, wfm_info::ScopeInfo)
    # From page 1398 in "Keysight InfiniiVision 4000 X-Series Oscilloscopes Programmer's Guide", version May 15, 2019:

    volt = ((convert.(Float64, wfm_data) .- wfm_info.y_reference) .* wfm_info.y_increment) .+ wfm_info.y_origin
    time = (( collect(0:(wfm_info.num_points-1))  .- wfm_info.x_reference) .* wfm_info.x_increment) .+ wfm_info.x_origin
    return ScopeData(wfm_info, V .* volt, u"s" .* time)
end


function fake_signal(n)
    fs = 2.0e9;
    f0 = 10.0e6;
    dt = 1/fs
    num_cycles = 10
    t = (0:(num_cycles*fs/f0-1)) .* dt
    s = sin.(2*pi*f0.*t)

    if n >= length(s)
        n_zeros = n-length(s)
        n_pre  = Int(floor(n_zeros/2))
        n_post = Int(ceil(n_zeros/2))
        out = [zeros(n_pre); s; zeros(n_post)]
    else
        out = s[1:n]
    end
    return out
end

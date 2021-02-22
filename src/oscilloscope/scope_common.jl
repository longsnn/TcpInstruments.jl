const RESOLUTION_MODE = Dict("+0" => "8bit", "+1" => "16bit", "+2" => "ASCII")
const TYPE = Dict("+0" => "Normal", "+1" => "Peak", "+2" => "Average",  "+3" => "High Resolution")

struct Waveform_info
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
end

struct Waveform_data
    info::Waveform_info
    volt::Array{Float64,1}
    time::Array{Float64,1}
end

status(obj, chan) = query(obj, "STAT? CHAN$chan") == "1" ? true : false

@recipe function plot(data::Waveform_data; label="Channel 1", xlabel="0", ylabel="Volts")
    time_unit, scaled_time = autoscale_seconds(data)
    title := "Oscilloscope ~ Volts Vs. Time (" * time_unit * ")"
    label := label
    if xlabel == "0"
        xlabel := "Time / " * time_unit
    else
        xlabel := xlabel
    end
    ylabel := ylabel * " / " * data.info.coupling
    return scaled_time, data.volt
end

function autoscale_seconds(data::Waveform_data)
    # temp = filter(x->x != 0, abs.(data.time))
    # @info "test", temp == data.time
    # m = min(temp...)
    unit = "seconds"
    time_array = data.time
    m = abs(min(data.time...))
    @info "MIN", m
    if m >= 1
        @info "SECONDS"
    elseif m < 1 && m >= 1e-3
        @info "MILISECONDS"
        unit = "miliseconds"
        time_array = data.time * 1e3
    elseif m < 1e-3 && m >= 1e-6
        @info "Microseconds"
        unit = "microseconds"
        time_array = data.time * 1e6
    elseif m < 1e-6 && m >= 1e-9
        @info "Nanoseconds"
        unit = "nanoseconds"
        time_array = data.time * 1e9
    else
        @info "Seconds unit not found"
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
    set_impedance_50ohm(scope, chan=1)

Set impedance to 50Ω
"""
set_impedance_50ohm(instr::Instrument; chan=1) = write(instr, ":CHANNEL$chan:IMPEDANCE FIFTY")
get_impedance(instr::Instrument; chan=1) = query(instr, ":CHANNEL$chan:IMPEDANCE?")
 
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
scope_waveform_num_points(instr::Instrument, num_points::Int) = write(instr, "WAVEFORM:POINTS $num_points")
scope_waveform_num_points(instr::Instrument, mode::String) = write(instr, "WAVEFORM:POINTS $mode")
scope_waveform_points_mode(instr::Instrument, mode_idx::Int) = write(instr, "WAVEFORM:POINTS:MODE $(WAVEFORM_POINTS_MODE[mode_idx])) #norm, max, raw
const WAVEFORM_POINTS_MODE = Dict(0=>"norm", 1=>"max")


function scope_parse_raw_waveform(wfm_data, wfm_info::Waveform_info) 
    # From page 1398 in "Keysight InfiniiVision 4000 X-Series Oscilloscopes Programmer's Guide", version May 15, 2019:
    
    volt = ((convert.(Float64, wfm_data) .- wfm_info.y_reference) .* wfm_info.y_increment) .+ wfm_info.y_origin
    time = (( collect(0:(wfm_info.num_points-1))  .- wfm_info.x_reference) .* wfm_info.x_increment) .+ wfm_info.x_origin
    @info "TIME", wfm_data[1:5]
    return Waveform_data(wfm_info, volt, time)
end

function scope_speed_mode(instr::Instrument, speed::Int)
    if speed == 1
        scope_waveform_mode_16bit(instr)
        scope_waveform_points_mode(instr, 1)
    elseif speed == 3
        scope_waveform_mode_16bit(instr)
        scope_waveform_points_mode(instr, 0)
    elseif speed == 5
        scope_waveform_mode_16bit(instr)
        scope_waveform_points_mode(instr, 1)
    elseif speed == 6
        scope_waveform_mode_16bit(instr)
        scope_waveform_points_mode(instr, 0)

    end
end

function scope_waveform_info_get(instr::Instrument, ch::Int)
    str = scope_waveform_preamble_get(instr)
    @info "preamble", str
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
    imp = get_impedance(instr; chan=ch)
    coupling = get_coupling(instr; chan=ch)
    low_pass_filter = get_lpf_state(instr; chan=ch)
    return Waveform_info(format, type, num_points, x_increment, x_origin, x_reference, y_increment, y_origin, y_reference, imp, coupling, low_pass_filter)
end 


function scope_read_binary_data(instr)


end


function scope_read_raw_waveform(instr::Instrument)
    write(instr, "WAV:DATA?")
    num_header_bytes = 2
    #@show header_a_str = read_n_bytes(instr, num_header_bytes)
    header_a_uint8 = read(instr.sock, 2)
    @assert (header_a_uint8[1] == UInt8('#'))  "The waveform data format is not formated as expected."
    header_b_length = parse(Int,convert(Char, header_a_uint8[2]))
    header_b_uint8 = read(instr.sock, header_b_length)
    num_waveform_samples = parse(Int,String(convert.(Char,header_b_uint8)))
    raw_data = read(instr.sock, num_waveform_samples);
    dummy = readline(instr.sock)
    return raw_data
end


function get_data(instr::Instrument, ch::Int)
    scope_waveform_source_set(instr, ch)
    #instrument_empty_buffer(instr)
    wfm_info = scope_waveform_info_get(instr, ch)
    @show wfm_info
    raw_data = scope_read_raw_waveform(instr);
    return scope_parse_raw_waveform(raw_data, wfm_info) 
end

# TODO: Make ch-vector only contain each channel maximum one time
function get_data(instr::Instrument, ch_vec::Vector{Int} = filter(x -> status(instr, x), 1:4))
    @info "Loading channels: $ch_vec"
    for ch in ch_vec
        if !status(instr, ch)
            error("Channel $ch is offline, data cannot be read")
        end
    end
    stop(instr) # Makes sure the data from each channel is from the same trigger event
    wfm_data = [get_data(instr, ch) for ch in ch_vec]
    run(instr)
    return wfm_data
end

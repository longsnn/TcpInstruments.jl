"""
    get_data(scope, channel_vector; check_channels=true)
    get_data(scope, channel)
    get_data(scope)

Grab data from the specified channel(s). If no channels are specified, data will be grabbed
from all available channels
"""
function get_data(instr::Instr{<:AgilentScope})
    ch_vec = get_valid_channels(instr)
    @info "Loading channels: $ch_vec"
    return get_data(instr, ch_vec; check_channels=false)
end 

function get_data(instr::Instr{<:AgilentScope}, ch_vec::Vector{Int}; check_channels=true)
    if check_channels
        unique!(ch_vec)
        valid_channels = get_valid_channels(instr)
        for ch in ch_vec
            if !(ch in valid_channels)
                error("Channel $ch is offline, data cannot be read")
            end
        end
    end
    stop(instr) # Makes sure the data from each channel is from the same trigger event
    wfm_data = [get_data(instr, ch) for ch in ch_vec]
    run(instr)
    return wfm_data
end

function get_data(instr::Instr{<:AgilentScope}, ch::Integer)
    set_waveform_source(instr, ch)
    wfm_info = get_waveform_info(instr, ch)
    raw_data = read_raw_waveform(instr);
    return parse_raw_waveform(raw_data, wfm_info)
end


function get_valid_channels(instr::Instr{<:AgilentScope})
    statuses = asyncmap(x->(x, channel_is_displayed(instr, x)), 1:4)
    filter!(x -> x[2], statuses)
    valid_channels = map(x -> x[begin], statuses)
    return valid_channels
end


set_waveform_source(instr::Instr{<:AgilentScope}, ch::Int) = write(instr, "WAVEFORM:SOURCE CHAN$ch")


"""
    get_waveform_info(scope, channel)

Grab channel information and return it in a `ScopeInfo`(@ref) struct
"""
function get_waveform_info(instr::Instr{<:AgilentScope}, ch::Integer)
    str = get_waveform_preamble(instr)
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
    impedance = get_impedance(instr; chan=ch)
    coupling =  get_coupling(instr; chan=ch)
    low_pass_filter =  get_lpf_state(instr; chan=ch)
    return ScopeInfo(format, type, num_points, x_increment, x_origin, x_reference, y_increment, y_origin, y_reference, impedance, coupling, low_pass_filter, ch)
end

const RESOLUTION_MODE = Dict("+0" => "8bit", "+1" => "16bit", "+2" => "ASCII")
const TYPE = Dict("+0" => "Normal", "+1" => "Peak", "+2" => "Average",  "+3" => "High Resolution")


function read_raw_waveform(instr::Instr{<:AgilentScope})
    write(instr, "WAV:DATA?")
    num_waveform_samples = get_num_waveform_samples(instr)
    raw_data = read(instr.sock, num_waveform_samples);
    # read end of line character
    dummy = readline(instr.sock)
    return raw_data
end


function get_num_waveform_samples(instr::Instr{<:AgilentScope})
    header = get_data_header(instr)
    num_header_description_bytes = 2
    num_waveform_samples = parse(Int, header[num_header_description_bytes+1:end])
    return num_waveform_samples
end


function get_data_header(instr::Instr{<:AgilentScope})
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


function parse_raw_waveform(wfm_data, wfm_info::ScopeInfo)
    # From page 1398 in "Keysight InfiniiVision 4000 X-Series Oscilloscopes Programmer's Guide", version May 15, 2019:

    volt = ((convert.(Float64, wfm_data) .- wfm_info.y_reference) .* wfm_info.y_increment) .+ wfm_info.y_origin
    time = (( collect(0:(wfm_info.num_points-1))  .- wfm_info.x_reference) .* wfm_info.x_increment) .+ wfm_info.x_origin
    return ScopeData(wfm_info, V .* volt, u"s" .* time)
end


"""
    get_coupling(scope; chan=1)

returns "AC" or "DC"
"""
get_coupling(instr::Instr{<:AgilentScope}; chan=1) = query(instr, "CHANNEL$chan:COUPLING?")


"""
    lpf_on(scope; chan=1)

Turn on an internal low-pass filter. When the filter is on, the bandwidth of
the specified channel is limited to approximately 25 MHz.
"""
lpf_on(instr::Instr{<:AgilentScope}; chan=1) = write(instr, "CHANNEL$chan:BWLIMIT ON")


"""
    lpf_off(scope; chan=1)

Turn off an internal low-pass filter.
"""
lpf_off(instr::Instr{<:AgilentScope}; chan=1) = write(instr, "CHANNEL$chan:BWLIMIT OFF")


"""
    get_lpf_state(scope; chan=1)

See state the internal low-pass filter:

returns "0" or "1"
"""
get_lpf_state(instr::Instr{<:AgilentScope}; chan=1) = query(instr, "CHANNEL$chan:BWLIMIT?")


"""
    set_impedance_1Mohm(scope; chan=1)

Set impedance to 1MΩ
"""
set_impedance_1Mohm(instr::Instr{<:AgilentScope}; chan=1) = write(instr, ":CHANNEL$chan:IMPEDANCE ONEMEG")


"""
    set_impedance_50ohm(scope; chan=1)

# Keywords
- `chan`: Specify channel: Default is 1

Set impedance to 50Ω
"""
set_impedance_50ohm(instr::Instr{<:AgilentScope}; chan=1) = write(instr, ":CHANNEL$chan:IMPEDANCE FIFTY")


"""
    get_impedance(scope)

# Keywords
- `chan`: Specify channel: Default is 1

# Returns
- `"FIFT"`: 50Ω
- `"ONEM"`: 1MΩ
"""
get_impedance(instr::Instr{<:AgilentScope}; chan::Integer=1) = query(instr, ":CHANNEL$chan:IMPEDANCE?")


"""
    run(scope)

Run Oscilloscope
"""
run(instr::Instr{<:AgilentScope}) = write(instr, "RUN")


"""
    stop(scope)
    
Stop Oscilloscope
"""
stop(instr::Instr{<:AgilentScope}) = write(instr, "STOP")


channel_is_displayed(instr::Instr{<:AgilentScope}, chan) = query(instr, "STAT? CHAN$chan") == "1" ? true : false
get_waveform_preamble(instr::Instr{<:AgilentScope}) = query(instr, "WAVEFORM:PREAMBLE?")
get_waveform_source(instr::Instr{<:AgilentScope}) = query(instr, "WAVEFORM:SOURCE?")

get_data_transfer_format(instr::Instr{<:AgilentScope}) = query(instr, "WAVEFORM:FORMAT?")
set_data_transfer_format_8bit(instr::Instr{<:AgilentScope}) = write(instr, "WAVEFORM:FORMAT BYTE")
set_data_transfer_format_16bit(instr::Instr{<:AgilentScope}) = write(instr, "WAVEFORM:FORMAT WORD")

get_waveform_num_points(instr::Instr{<:AgilentScope}) = query(instr, "WAVEFORM:POINTS?")
set_waveform_num_points(instr::Instr{<:AgilentScope}, num_points::Integer) = write(instr, "WAVEFORM:POINTS $num_points")
set_waveform_num_points(instr::Instr{<:AgilentScope}, mode::String) = write(instr, "WAVEFORM:POINTS $mode")

get_waveform_points_mode(instr::Instr{<:AgilentScope}) = query(instr, "WAVEFORM:POINTS:MODE?")

"""
    set_waveform_points_mode(scope, mode)

Set which data to transfer when using `get_data`(@ref)

Inputs:
`scope`: handle to the connected oscilloscope
`mode`: 
- `:NORMAL`: transfer the measurement data
- `:RAW`: transfer the raw acquisition data
"""
function set_waveform_points_mode(instr::Instr{<:AgilentScope}, mode::Symbol)
    if mode ∈ [:NORMAL, :RAW]
        write(instr, "WAVEFORM:POINTS:MODE $(mode)")
    else
        error("Mode $mode not recognized. Specify :NORMAL or :RAW instead")
    end
    return nothing
end


function set_speed_mode(instr::Instr{<:AgilentScope}, speed::Integer)
    if speed == 1
        set_data_transfer_format_16bit(instr)
        set_waveform_points_mode(instr, 1)
    elseif speed == 3
        set_data_transfer_format_16bit(instr)
        set_waveform_points_mode(instr, 0)
    elseif speed == 5
        set_data_transfer_format_8bit(instr)
        set_waveform_points_mode(instr, 1)
    elseif speed == 6
        set_data_transfer_format_8bit(instr)
        set_waveform_points_mode(instr, 0)
    end
end

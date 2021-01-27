
using Printf



scope_stop(instr::Instrument) = write(instr, "STOP")
scope_continue(instr::Instrument) = write(instr, "RUN")

scope_waveform_source_set(instr, ch::Int) = write(instr, @sprintf("waveform:source chan%i", ch))
scope_waveform_source_get(instr) = query(instr, "waveform:source?")
scope_waveform_mode_8bit(instr::Instrument) = write(instr, "waveform:format BYTE")
scope_waveform_mode_16bit(instr::Instrument) = write(instr, "waveform:format WORD")
scope_waveform_num_points(instr::Intrument, num_points::Int) = write(instr, @sprintf("waveform:points %i", num_points))
scope_waveform_num_points(instr::Intrument, mode::String) = write(instr, @sprintf("waveform:points %s", mode))
scope_waveform_points_mode(instr::Intrument, mode_idx::Int) = write(instr, @sprintf("waveform:points:mode %s", WAVEFORM_POINTS_MODE[mode_idx])) #norm, max, raw
const WAVEFORM_POINTS_MODE = Dict(0=>"norm", 1=>"max")


function scope_parse_raw_waveform(wfm_data, wfm_info::Waveform_info) 
    volt = ((convert.(Float64, wfm_data) .- wfm_info.y_reference) .* wfm_info.y_increment) .+ wfm_info.y_origin
    time = (((1:wfm_info.num_points) .- wfm_info.y_reference) .* wfm_info.increment) .+ wfm_info.origin
    return waveform_data(wfm_info, volt, time)
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
end

struct Waveform_data
    info::waveform_info
    volt::Array{Float64,1}
    time::Array{Float64,1}
end

function scope_waveform_info_get(instr::Instrument)
    str = query(instr, "waveform:preamble?")
    str_array = split(str, ",")
    #@printf("str: %s\n", str)
    #@printf("str_array: %s\n", str_array)
    format = RESOLUTION_MODE[str_array[1]]
    type = TYPE[str_array[2]]
    num_points = parse(Int64, str_array[3])
    count = parse(Int64, str_array[4]) # is always one
    x_increment = parse(Float64, str_array[5])
    x_origin = parse(Float64, str_array[6])
    x_reference = parse(Float64, str_array[7])
    y_increment = parse(Float64, str_array[8])
    y_origin = parse(Float64, str_array[9])
    y_reference = parse(Float64, str_array[10])
    return Waveform_info(format, type, num_points, x_increment, x_origin, x_reference, y_increment, y_origin, y_reference)
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

function scope_get_ch_data(instr::Instrument, ch::Int)
    scope_waveform_source_set(instr, ch)
    instrument_clear(instr)
    #scope_stop(instr)
    #instrument_empty_buffer(instr)
    wfm_info = scope_waveform_info_get(instr)
    #@show wfm_info
    raw_data = scope_read_raw_waveform(instr);
    #scope_continue(instr)

    return scope_parse_raw_waveform(raw_data, wfm_info) 
end

# TODO: Make ch-vector only contain each channel maximum one time
scope_get_ch_data(instr::Instrument, ch_vec::Vector{Int}) = [scope_get_ch_data(instrument, ch) for ch in ch_vec]


include("./Agilent4294A.jl")
include("./Agilent4395A.jl")


"""
    get_impedance_analyzer_info(ia::Instr{<:ImpedanceAnalyzer})
Get current acquisition parameters from the impedance analyzer

dc_voltage [V]
ac_voltage [V]
num_averages
bandwidth_level [1, 2, 3, 4, 5]
point_delay_time [s]
sweep_delay_time [s]
sweep_direction ["UP", "DOWN"]
"""
function get_impedance_analyzer_info(ia::Instr{<:ImpedanceAnalyzer})
    dc_voltage = get_volt_dc(ia)
    ac_voltage = get_volt_ac(ia)
    num_averages = get_num_averages(ia)
    bandwidth_level = get_bandwidth(ia)
    point_delay_time = get_point_delay_time(ia)
    sweep_delay_time = get_sweep_delay_time(ia)
    sweep_direction = get_sweep_direction(ia)
    return ImpedanceAnalyzerInfo(dc_voltage, ac_voltage, num_averages, bandwidth_level, point_delay_time, sweep_delay_time, sweep_direction)
end


"""
    get_num_averages(ia::Instr{<:ImpedanceAnalyzer})
Get the number of sweep averages being used
"""
function get_num_averages(ia::Instr{<:ImpedanceAnalyzer})
    if is_average_mode_on(ia)
        write(ia, "AVERFACT?")
        num_averages = parse(Float64, read(ia))
    else
        num_averages = 1
    end
    return num_averages
end


"""
    is_average_mode_on(ia::Instr{<:ImpedanceAnalyzer})
Get status for whether average mode is on
Output is [true, false]
"""
function is_average_mode_on(ia::Instr{<:ImpedanceAnalyzer})
    write(ia, "AVER?")
    return parse(Bool, read(ia))
end


"""
    get_point_delay_time(ia::Instr{<:ImpedanceAnalyzer})
Get time delay value used between data point acquisitions
Output is in [s]
"""
function get_point_delay_time(ia::Instr{<:ImpedanceAnalyzer})
    write(ia, "PDELT?")
    point_delay_time = parse(Float64, read(ia)) * u"s"
    return point_delay_time
end


"""
    get_sweep_delay_time(ia::Instr{<:ImpedanceAnalyzer})
Get time delay value used between sweep acquisitions
Output is in [s]
"""
function get_sweep_delay_time(ia::Instr{<:ImpedanceAnalyzer})
    write(ia, "SDELT?")
    sweep_delay_time = parse(Float64, read(ia)) * u"s"
    return sweep_delay_time
end


"""
    get_sweep_direction(ia::Instr{<:ImpedanceAnalyzer})
Get acquisition sweep direction
Output is ["UP", "DOWN"]

"UP": sweeps along increasing values (left to right on screen)
"DOWN": sweeps along decreasing values (right to left on screen)
"""
function get_sweep_direction(ia::Instr{<:ImpedanceAnalyzer})
    write(ia, "SWED?")
    sweep_direction = read(ia)
    return sweep_direction
end


"""
    get_frequency(ia::Instr{<:ImpedanceAnalyzer})
Get an array of frequency values with the same number of points as the data trace
Output is in [MHz]
"""
function get_frequency(ia::Instr{<:ImpedanceAnalyzer})
    start_frequency = get_frequency_lower_bound(ia)
    end_frequency = get_frequency_upper_bound(ia)
    num_points = get_num_data_points(ia)
    frequency = collect(LinRange(start_frequency, end_frequency, num_points))
    return frequency
end


"""
    get_frequency_limits(instr)

# Returns
`Tuple{Frequency, Frequency}`: (lower_limit, upper_limit)
"""
function get_frequency_limits(ia::Instr{<:ImpedanceAnalyzer})
    lower_bound = get_frequency_lower_bound(ia)
    upper_bound = get_frequency_upper_bound(ia)
    return lower_bound, upper_bound
end

function get_frequency_lower_bound(ia::Instr{<:ImpedanceAnalyzer})
    write(ia, "STAR?")
    lower_bound = parse(Float64, read(ia)) * u"Hz"
    return uconvert(u"MHz", lower_bound)
end

function get_frequency_upper_bound(ia::Instr{<:ImpedanceAnalyzer})
    write(ia, "STOP?")
    upper_bound = parse(Float64, read(ia)) * u"Hz"
    return uconvert(u"MHz", upper_bound)
end


"""
    set_frequency_limits(instr, lower_limit, upper_limit)

"""
function set_frequency_limits(ia::Instr{<:ImpedanceAnalyzer}, lower_bound::Frequency, upper_bound::Frequency)
    if lower_bound > upper_bound
        error("Lower bound ($lower_bound) is larger than upper bound ($upper_bound)")
    end
    set_frequency_lower_bound(ia, lower_bound)
    set_frequency_upper_bound(ia, upper_bound)
    return nothing
end

function set_frequency_lower_bound(ia::Instr{<:ImpedanceAnalyzer}, lower_bound::Frequency)
    write(ia, "STAR $(raw(lower_bound))")
    return nothing
end

function set_frequency_upper_bound(ia::Instr{<:ImpedanceAnalyzer}, upper_bound::Frequency)
    write(ia, "STOP $(raw(upper_bound))")
    return nothing
end


"""
    set_num_data_points(instr, num_points)

"""
function set_num_data_points(ia::Instr{<:ImpedanceAnalyzer}, num_data_points)
    write(ia, "POIN $num_data_points")
    return nothing
end


"""
    get_num_data_points(instr)

"""
function get_num_data_points(ia::Instr{<:ImpedanceAnalyzer})
    write(ia, "POIN?")
    num_data_points = parse(Int64, read(ia))
    return num_data_points
end


"""
    get_volt_dc(instr)

"""
get_volt_dc(obj::Instr{<:ImpedanceAnalyzer}) = f_query(obj, "DCV?") * V

"""
    set_volt_dc(instr, volts)

"""
set_volt_dc(obj::Instr{<:ImpedanceAnalyzer}, num::Voltage) = write(obj, "DCV $(raw(num))")

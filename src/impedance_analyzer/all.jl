include("./Agilent4294A.jl")
include("./Agilent4395A.jl")

"""
    get_frequency_limits(instr)

# Returns
`Tuple{Frequency, Frequency}`: (lower_limit, upper_limit)
"""
function get_frequency_limits(ia::Instr{T}) where T <: ImpedanceAnalyzer
    lower_bound = get_frequency_lower_bound(ia)
    upper_bound = get_frequency_upper_bound(ia)
    return lower_bound, upper_bound
end

function get_frequency_lower_bound(ia::Instr{T}) where T <: ImpedanceAnalyzer
    write(ia, "STAR?")
    lower_bound = parse(Float64, read(ia)) * u"Hz"
    return uconvert(u"MHz", lower_bound)
end

function get_frequency_upper_bound(ia::Instr{T}) where T <: ImpedanceAnalyzer
    write(ia, "STOP?")
    upper_bound = parse(Float64, read(ia)) * u"Hz"
    return uconvert(u"MHz", upper_bound)
end


"""
    set_frequency_limits(instr, lower_limit, upper_limit)

"""
function set_frequency_limits(ia::Instr{T}, lower_bound::Frequency, upper_bound::Frequency) where T <: ImpedanceAnalyzer
    if lower_bound > upper_bound
        error("Lower bound ($lower_bound) is larger than upper bound ($upper_bound)")
    end
    set_frequency_lower_bound(ia, lower_bound)
    set_frequency_upper_bound(ia, upper_bound)
    return nothing
end

function set_frequency_lower_bound(ia::Instr{T}, lower_bound::Frequency) where T <: ImpedanceAnalyzer
    write(ia, "STAR $(raw(lower_bound))")
    return nothing
end

function set_frequency_upper_bound(ia::Instr{T}, upper_bound::Frequency) where T <: ImpedanceAnalyzer
    write(ia, "STOP $(raw(upper_bound))")
    return nothing
end


"""
    set_num_data_points(instr, num_points)

"""
set_num_data_points(obj::Instr{T}, n) where (T <: ImpedanceAnalyzer) =
    write(obj, "POIN $n")

"""
    get_num_data_points(instr)

"""
get_num_data_points(obj::Instr{T}) where (T <: ImpedanceAnalyzer) =
    i_query(obj, "POIN?")

"""
    get_volt_dc(instr)

"""
get_volt_dc(obj::Instr{T}) where (T <: ImpedanceAnalyzer) =
    f_query(obj, "DCV?") * V

"""
    set_volt_dc(instr, volts)

"""
set_volt_dc(obj::Instr{T}, num::Voltage) where (T <: ImpedanceAnalyzer) =
    write(obj, "DCV $(raw(num))")

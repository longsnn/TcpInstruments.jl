include("./Agilent4294A.jl")
include("./Agilent4395A.jl")

"""
    get_frequency_limits(instr)

# Returns
`Tuple{Frequency, Frequency}`: (lower_limit, upper_limit)
"""
get_frequency_limits(obj::Instr{T}) where (T <: ImpedanceAnalyzer) =
    f_query(obj, "STAR?") * u"Hz", f_query(obj, "STOP?") * u"Hz"

"""
    set_frequency_limits(instr, lower_limit, upper_limit)

"""
function set_frequency_limits(
    obj::Instr{T},
    start::Frequency,
    stop::Frequency
) where {T <: ImpedanceAnalyzer}
    start = raw(start)
    stop = raw(stop)
    write(obj, "STAR $start; STOP $stop")
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

get_volt_limit_dc(obj::Instr{T}) where (T <: ImpedanceAnalyzer) =
    f_query(obj, "MAXDCV?") * V

set_volt_limit_dc(obj::Instr{T}, v::Voltage) where (T <: ImpedanceAnalyzer) =
    write(obj, "MAXDCV $(raw(v))")

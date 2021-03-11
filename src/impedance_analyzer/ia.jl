include("./Agilent4294A.jl")
include("./Agilent4395A.jl")

"""
    get_frequency_limits(instr)

# Returns
`Tuple{Float64, Float64}`: (lower_limit, upper_limit)
"""
get_frequency_limits(obj::Instr{T}) where (T <: ImpedanceAnalyzer) =
    f_query(obj, "STAR?"), f_query(obj, "STOP?")

"""
    set_frequency_limits(instr, lower_limit, upper_limit)

"""
set_frequency_limits(obj::Instr{T}, start, stop) where (T <: ImpedanceAnalyzer) =
    write(obj, "STAR $start; STOP $stop")

"""
    set_num_data_points(instr, num_points)

"""
set_num_data_points(obj::Instr{T}, n) where (T <: ImpedanceAnalyzer) =
    write(obj, "POIN $n")

"""
    get_num_data_points(instr)

"""
get_num_data_points(obj::Instr{T}) where (T <: ImpedanceAnalyzer) =
    f_query(obj, "POIN?")

"""
    get_volt_dc(instr)

"""
get_volt_dc(obj::Instr{T}) where (T <: ImpedanceAnalyzer) =
    f_query(obj, "DCV?")

"""
    set_volt_dc(instr, volts)

"""
set_volt_dc(obj::Instr{T}, num) where (T <: ImpedanceAnalyzer) =
    write(obj, "DCV $num")

"""
    get_volt_limit_dc(instr)

"""
get_volt_limit_dc(obj::Instr{T}) where (T <: ImpedanceAnalyzer) =
    f_query(obj, "MAXDCV?")

"""
    set_volt_limit_dc(instr, volt_limit)

"""
set_volt_limit_dc(obj::Instr{T}, v) where (T <: ImpedanceAnalyzer) =
    write(obj, "MAXDCV $v")


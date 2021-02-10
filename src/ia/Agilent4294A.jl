"""

# Available functions
- `initialize()`
- `terminate()`
- `get_frequency_range()`
- `set_frequency_range([start, stop]) # in hertz)
- `get_num_data_points(x)`
    - number of points on x-axis / number of samples
- `set_num_data_points(x)`
- `get_impedance()` # get the data
- `set_volt_ac`
- `get_volt_ac`
- `get_volt_dc`
- `set_volt_dc`
- `bandwidth ({1,2,3,4,5})`
    - 1 -> lowest bandwidth, 35 -> highest bandwidth


"""
struct Agilent4294A <: ImpedanceAnalyzer end
# TODO: Spectrum or impedance mode
# TODO: initialize? write(obj, "PRES; ZA; CHAN 1")
set_frequency_limits(obj, start, stop) = write(obj, "STAR $start; STOP $stop")
get_frequency_limits(obj) = query(obj, "STAR?"), query(obj, "STOP?")

get_volt_limit_dc(obj) = query(obj, "MAXDCV?")
set_volt_limit_dc(obj, num) = query(obj, "MAXDCV $num")

get_volt_ac(obj) = query(obj, "DCV?")
set_volt_ac(obj, num) = query(obj, "DCV $num")




set_num_data_points(obj, num) = write(obj, "POIN")
get_num_data_points(obj, num) = query(obj, "POIN?")

"""
P. 188
Must be in ZA mode
IMPH
COMP
"""
get_impedance(obj::Instr{Agilent4294A}) = write(obj, "MEAS IMAG")

get_channel(i::Instr{Agilent4294A}) = query(i, "TRAC?") == "A" ? 1 : 2

function set_channel!(i::Instr{Agilent4294A}, n::Int)
    @assert n in [1,2] "Channel cannot be: $n (must be 1 or 2)"
    n == 1 ? write(i, "TRAC A") :  write(i, "TRAC B")
end

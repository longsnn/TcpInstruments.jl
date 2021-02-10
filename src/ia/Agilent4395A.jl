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
struct Agilent4395A <: ImpedanceAnalyzer end

"""
[Start] Lower Frequency
[Stop] Upper Frequency
"""
set_frequency_limits(i::Instr{Agilent4294A}, start, stop) =
    write(obj, "STAR $start; STOP $stop")

"""
[Start] Lower Frequency
[Stop] Upper Frequency
"""
get_frequency_limits(obj::Instr{Agilent4294A}) =
    query(obj, "STAR?"), query(obj, "STOP?")

"""
Pg.  B-3

2, 10, 30, 100, 300, 1000 (=1k), 3000 (=3k), 10000 (=10k),
30000 (=30k) (Network and impedance analyzers)
"""
set_bandwith(i::Instr{Agilent4294A}, n) = write(i, "BW $n")


set_num_data_points(obj::Instr{Agilent4294A}, num) =
    write(obj, "POIN")
get_num_data_points(obj::Instr{Agilent4294A}, num) =
    query(obj, "POIN?")

"""
P. 3-10

Error corrected data
The results of error correction are stored in the data arrays as complex number pairs.
Formatted data

This is the array of data being displayed. It reflects all post-processing functions such as
electrical delay, and the units of the array read out depends on the current display format.
"""
function get_impedance(obj::Instr{Agilent4294A}) 
    write(obj, "MEAS IMAG")
    #write(obj, "FORM3")
    write(obj, "FORM4")
    @info query(obj, "OUTPDTRC?") 
    @info query(obj, "OUTPSWPRM?")
end

# TODO: Spectrum or impedance mode query(obj, "ZA?")
# TODO: initialize? write(obj, "PRES; ZA; CHAN 1")

get_channel(i::Instr{Agilent4395A}) = query(i, "TRAC?") == "A" ? 1 : 2

set_channel!(i::Instr{Agilent4395A}, n) = write(i, "CHAN $n")

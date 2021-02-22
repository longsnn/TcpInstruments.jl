"""
http://literature.cdn.keysight.com/litweb/pdf/04395-90031.pdf
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
Returns device bandwidth
"""
get_bandwith(i::Instr{Agilent4395A}) = query(i, "BW?")

"""
Pg.  B-3

2, 10, 30, 100, 300, 1000 (=1k), 3000 (=3k), 10000 (=10k),
30000 (=30k) (Network and impedance analyzers)
"""
set_bandwith(i::Instr{Agilent4395A}, n) = write(i, "BW $n")


"""
P. 3-10

Error corrected data
The results of error correction are stored in the data arrays as complex number pairs.
Formatted data

This is the array of data being displayed. It reflects all post-processing functions such as
electrical delay, and the units of the array read out depends on the current display format.
"""
function get_impedance(obj::Instr{Agilent4395A}) 
    write(obj, "MEAS IMAG")
    #write(obj, "FORM3")
    write(obj, "FORM4")
    @info query(obj, "OUTPDTRC?") 
    @info query(obj, "OUTPSWPRM?")
end

"""
Returns 1 or 2 depending on current channel
"""
get_channel(i::Instr{Agilent4395A}) = query(i, "CHAN?")

"""
    set_channel(i, channel_number)

Uses.
```
set_channel(i, 1)

set_channel(i, 2)
```
"""
set_channel(i::Instr{Agilent4395A}, n) = write(i, "CHAN $n")

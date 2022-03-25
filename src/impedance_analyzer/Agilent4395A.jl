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

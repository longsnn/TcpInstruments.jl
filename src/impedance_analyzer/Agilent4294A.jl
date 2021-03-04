"""
http://literature.cdn.keysight.com/litweb/pdf/04294-90061.pdf
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
    - 1 -> lowest bandwidth, 5 -> highest bandwidth


"""
struct Agilent4294A <: ImpedanceAnalyzer end

"""
Returns bandwidth level (1-5)
"""
get_bandwith(i::Instr{Agilent4294A}) = write(i, "BWFACT?")

"""
Pg. 274

1. (Initial value) Specifies bandwidth 1 (shortest measurement time)
2. Specifies bandwidth 2
3. Specifies bandwidth 3
4. Specifies bandwidth 4
5. Specifies bandwidth 5 (longest measurement time, accurate
measurement).
"""
function set_bandwith(i::Instr{Agilent4294A}, n) 
    @assert n in 1:5 "$n must be an int between 1 and 5"
    write(i, "BWFACT $n")
end

"""
Returns oscillator (ac) voltage
"""
get_volt_ac(i::Instr{Agilent4294A}) = query(i, "POWE?")

"""
Range For voltage setting: 5E-3 to 1
"""
set_volt_ac(i::Instr{Agilent4294A}, n) = write(i, "POWE $n"*"V")

function get_impedance(obj::Instr{Agilent4294A}; complex=false) 
    data = query(obj, "OUTPDTRC?"; timeout=3)
    data = split(data, ',')
    arr = []
    get_f(i) = parse(Float64, data[i])
    for i in 1:Int(length(data) / 2)
        real_i = i * 2 - 1
        img_i = i * 2
        push!(arr, (get_f(real_i), get_f(img_i)))
    end
    return arr
end

@recipe function f(impedance::Array{Tuple{Float64, Float64}, 1}; complex=false)
    title := "Impedance"
    layout := (2, 1)
    real_label, imag_label = if complex 
        "Real", "Imaginary" 
    else
        "Amplitude", "Phase"
    end
    label := [real_label, imag_label]
    @series begin 
        subplot := 1
        label := real_label
        legend := :outertopright
        map(x->x[1], impedance)
    end
    @series begin 
        title := ""
        subplot := 2
        label := imag_label
        legend := :outertopright
        linecolor := :red
        map(x->x[2], impedance)
    end
end


get_channel(i::Instr{Agilent4294A}) = query(i, "TRAC?") == "A" ? 1 : 2

function set_channel(i::Instr{Agilent4294A}, n::Int)
    @assert n in [1,2] "Channel cannot be: $n (must be 1 or 2)"
    n == 1 ? write(i, "TRAC A") :  write(i, "TRAC B")
end

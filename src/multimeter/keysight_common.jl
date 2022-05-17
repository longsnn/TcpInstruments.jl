include("./Keysight34465A.jl")

"""
    get_tc_temperature(multimeter)

Perform take a measurement with the probe mode set to thermocouple
"""
function get_tc_temperature(obj::Instr{<:KeysightMultimeter})
    units = get_temp_unit(obj)
    return f_query(obj, "MEASURE:TEMPERATURE? TC"; timeout=0) * units
end

"""
    set_tc_type(multimeter; type="K")

# Keywords
- `type`: Can be E, J, K, N, R, T (Defaults to K)
"""
function set_tc_type(obj::Instr{<:KeysightMultimeter}; type="K")
    if !(string(type) in ["E", "J", "K", "N", "R", "T"])
        error("$type must be one of [E, J, K, N, R, T]")
    end
    write(obj, "CONFIGURE:TEMPERATURE TC,$type")
end




"""
    get_voltage(instr::KeysightDMM34465A};
        type::String = "DC",
        resolution::Union{String,Unitful.Voltage} = "",
        plc::Union{String,Unitful.Voltage} = ""
    )::Unitful.Voltage

Returns the voltage from the multimeter.

### Input

- `type`        --  "DC" | "AC" (Default DC)
- `range`       --  Can be a String or a Unitful.Voltage.
                    Valid string values: "AUTO", "DEF", "MIN", or "MAX".
                    Valid voltage values: See `Range` column in table below.
- `plc`         --  Can be a String or a Unitful.Voltage.
                    Valid String values: "DEF", "MIN", or "MAX".
                    Valid voltage values: See 'plc' column in table below.


```
Keysight 34465A
Power Line Cycles (PLC)  100        10        1      0.2     0.06     0.02    0.006   0.002   0.001
Aperture (60 Hz Power)  1.67 s   0.167 s   16.7 ms     3 ms     1 ms   0.3 ms  100 µs   40 µs   20 µs
Aperture (50 Hz Power)     2 s     0.2 s     20 ms     3 ms     1 ms   0.3 ms  100 µs   40 µs   20 µs
ResFactor               0.03 ppm   0.1 ppm  0.3 ppm  0.7 ppm  1.5 ppm    3 ppm   6 ppm  15 ppm  30 ppm
Range                                              Resolution
  1 mV                   30 pV     100 pV   300 pV   700 pV   1.5 nV     3 nV    6 nV   15 nV   30 nV
 10 mV                  300 pV       1 nV     3 nV     7 nV    15 nV    30 nV   60 nV  150 nV  300 nV
100 mV                    3 nV      10 nV    30 nV    70 nV   150 nV   300 nV  600 nV  1.5 µV    3 µV
  1 V                    30 nV     100 nV   300 nV   700 nV   1.5 µV     3 µV    6 µV   15 µV   30 µV
 10 V                   300 nV       1 µV     3 µV     7 µV    15 µV    30 µV   60 µV  150 µV  300 µV
100 V                     3 V       10 V     30 V     70 V    150 V    300 V   600 V   1.5 V     3 V
  1 kV                   30 V      100 V    300 V    700 V    1.5 V      3 V     6 V    15 V    30 V
```

### Output

A single Float64 with unit of volt (from Unitful package).

"""
get_voltage(instr::KeysightDMM34465A; kwargs...) = get_voltage_worker(instr; kwargs...)




"""
    get_voltage(instr::Instr{<:KeysightMultimeter};
        type::String = "DC",
        resolution::Union{String,Unitful.Voltage} = "",
        range::Union{String,Unitful.Voltage} = ""
    )::Unitful.Voltage

Returns the voltage from the multimeter.

### Input

- `type`        --  "DC" | "AC" (Default DC)
- `range`       --  Can be a String or a Unitful.Voltage.
        Valid string values: "AUTO", "DEF", "MIN", or "MAX".
        Valid voltage values: See `Range` column in table below.
- `plc`  --  Can be a String or a Unitful.Voltage.
        Valid String values: "DEF", "MIN", or "MAX".
        Valid voltage values: See 'plc' column in table below.
See the manual for the allowed range and resolution combinations.

### Output

A single Float64 with unit of volt (from Unitful package).

"""
get_voltage(instr::Instr{<:KeysightMultimeter}; args...) = get_voltage_worker(instr; args...)


"""
get_voltage_worker
Internal function that's called by get_voltage()
"""
function get_voltage_worker(instr::Instr{<:KeysightMultimeter};
        type::String="DC",
        range::Union{String,Unitful.Voltage} = "AUTO",
        plc = 10
    )
    verify_voltage_type(type)
    verify_voltage_range(range)
    verify_voltage_power_line_cycles(instr, plc)

    if range == "AUTO" || type == "AC"
        return f_query(instr, "MEASURE:VOLTAGE:$type? $range "; timeout=0) * V
    else
        resolution = range_plc_to_resolution(instr, range, plc)
        return f_query(instr, "MEASURE:VOLTAGE:$type? $range, $resolution "; timeout=0) * V
    end
end

verify_voltage_type(type) = !(type in ["AC","DC"]) && error("Voltage type \"$type\" is not valid!\nIt's value must be \"AC\" or \"DC\"")
verify_voltage_range(range::Unitful.Voltage) = !(range in [100u"mV", 1u"V", 10u"V", 100u"V", 1u"kV"]) && error("range value of \"$range\" is not valid!\nIt's voltage value must be one of: 0.1 V, 1 V, 10 V, 100 V, or 1 kV.")
verify_voltage_range(range::String) = !(range in ["", "AUTO", "DEFAULT", "DEF", "MIN", "MAX", ]) && error("range value of \"$range\" is not valid!\nIt's string value must be \"AUTO\", \"DEF\", \"MIN\", or \"MAX\".")

function array_to_str(vs::AbstractArray)
    array_str = "["
    for v in vs
        push!(array_str, "$v,")
    end
    push!(array_str, "]")
    return array_str
end

"""
    get_current(obj::Instr{<:KeysightMultimeter}; type="DC")

Returns current

# Keywords
- `type`: "DC" | "AC" (Default DC)

"""
function get_current(obj::Instr{<:KeysightMultimeter}; type="DC")
    !(type in ["AC","DC"]) && error("$type not valid!\nMust be AC or DC")
    f_query(obj, "MEASURE:CURRENT:$type?"; timeout=0) * A
end

"""
    get_resistance(multimeter; wire=2)
    get_resistance(multimeter; wire=4)
Returns resistance

# Keywords
- `wire`: 2 | 4 (Required)

"""
function get_resistance(obj::Instr{<:KeysightMultimeter}; wire)
    if wire == 2
        f_query(obj, "MEASURE:RESISTANCE?"; timeout=0) * R
    elseif wire == 4
        f_query(obj, "MEASURE:FRESISTANCE?"; timeout=0) * R
    else
        error("wire flag must be 2 or 4 not $wire")
    end
end

"""
    set_temp_unit_celsius(multimeter)

Sets the temperature unit to celcius
"""
set_temp_unit_celsius(obj::Instr{<:KeysightMultimeter}) =
    write(obj, "UNIT:TEMPERATURE C")

"""
    set_temp_unit_farenheit(multimeter)

Sets the temperature unit to farenheit
"""
set_temp_unit_farenheit(obj::Instr{<:KeysightMultimeter}) =
    write(obj, "UNIT:TEMPERATURE F")

"""
    set_temp_unit_kelvin(multimeter)

Sets the temperature unit to kelvin
"""
set_temp_unit_kelvin(obj::Instr{<:KeysightMultimeter}) =
    write(obj, "UNIT:TEMPERATURE K")

"""
    get_temp_unit(multimeter)

Returns C, F or K depending on the set temperature unit
"""
function get_temp_unit(obj::Instr{<:KeysightMultimeter})
   units = query(obj, "UNIT:TEMPERATURE?")
   return if units == "C"
       u"C"
   elseif units == "F"
       u"F"
   elseif units == "K"
       u"K"
   else
       error("Expected [C, F, K]. Got: $units")
   end
end


"""
    get_channel(obj::Instr{<:KeysightMultimeter})
Indicates which input terminals are selected on the front panel
Front/Rear switch. This switch is not programmable; this query reports
the position of the switch, but cannot change it.

Do not toggle the Front/Rear switch with active signals on the
terminals. This switch is not intended to be used in this way and may be damaged by high voltages or currents, possibly compromising the
instrument's safety features.

# Returns
- "FRON" or "REAR"
"""
get_channel(obj::Instr{<:KeysightMultimeter}) =
    query(obj, "ROUTE:TERMINALS?")

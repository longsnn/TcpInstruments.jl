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
        range::Union{String,Unitful.Voltage} = ""
    )::Unitful.Voltage

Returns the voltage from the multimeter.

### Input

- `type`        --  "DC" | "AC" (Default DC)
- `range`       --  Can be a String or a Unitful.Voltage.
                    Valid string values: "AUTO", "DEF", "MIN", or "MAX".
                    Valid voltage values: See `Range` column in table below.
- `resolution`  --  Can be a String or a Unitrful.Voltage.
                    Valid String values: "DEF", "MIN", or "MAX".
                    Valid voltage values: After selecting a `range` see the resolution values on the same
                    row in the table below.


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
- `resolution`  --  Can be a String or a Unitrful.Voltage.
        Valid String values: "DEF", "MIN", or "MAX".
        Valid voltage values: After selecting a `range` see the resolution values on the same
        row in the table below.

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
        resolution::Union{String,Unitful.Voltage} = "",
        range::Union{String,Unitful.Voltage} = "",
    )
    verify_voltage_type(type)
    verify_resolution(resolution)
    verify_range(range)
    verify_resolution_and_range(resolution, range)
    if isempty(resolution)
        f_query(instr, "MEASURE:VOLTAGE:$type? resolution "; timeout=0) * V
    else
        f_query(instr, "MEASURE:VOLTAGE:$type? reange,resolution"; timeout=0) * V
    end
end
verify_voltage_type(type) = !(type in ["AC","DC"]) && error("Voltage type \"$type\" is not valid!\nIt's value must be \"AC\" or \"DC\"")
verify_range(range::Unitful.Voltage) = !(range in [100u"mV", 1u"V", 10u"V", 100u"V", 1u"kV"]) && error("range value of \"$range\" is not valid!\nIt's voltage value must be one of: 0.1 V, 1 V, 10 V, 100 V, or 1 kV.")
verify_range(range::String) = !(range in ["", "AUTO", "DEFAULT", "DEF", "MIN", "MAX", ]) && error("range value of \"$range\" is not valid!\nIt's string value must be \"AUTO\", \"DEF\", \"MIN\", or \"MAX\".")
verify_resolution(resolution::String) = !(resolution in ["", "DEF", "MIN", "MAX"]) && error("resolution value of \"$resolution\" is not valid!\nIt's string value must be \"DEF\", \"MIN\", or \"MAX\".")

function verify_resolution(resolution::Unitful.Voltage)
    # Valid values taken from page 453 in "Keysight Truevolt Series Operating and Service Guide"
    # This assumes Keysight DMM 34465A
    plc100  = [30e-12, 300e-12, 3e-9, 3e-8, 3e-7, 3e-6, 3e-5, 3e-4, 3e-3, 3e-2, 3e-1, 3e0, 3e1, 3e2]*u"V"
    plc10   = [100e-12, 1e-9, 1e-8, 1e-7, 1e-6, 1e-5, 1e-4, 1e-3, 1e-2, 1e-1, 1e0, 1e1, 1e2]*u"V"
    plc1    = [300]*u"V"
    plc02   = [700e-12, 7e-9, 7e-8, 7e-7, 7e-6, 7e-5, 7e-4, 7e3, 7e-2, 7e-1, 7e0, 7e1, 7e2]*u"V"
    plc006  = [1.5e-9, 1.5e-8, 1.5e-7, 1.5e-6, 1.5e-5, 1.5e-4, 1.5e-3, 1.5e-2, 1.5e-1, 1.5e0, 1.5e1, 1.5e2, 1.5e3]*u"V"
    plc002  = [3e3]*u"V"
    plc0006 = [6e-9, 6e-8, 6e-7, 6e-6, 6e-5, 6e-4, 6e-3, 6e-2, 6e-1, 6e0, 6e1, 6e2, 6e3]*u"V"
    plc0002 = [1.5e4]*u"V"
    plc0001 = [30e3]*u"V"
    all_valid_values = sort(cat(plc100, plc10, plc1, plc02, plc006, plc002, plc0006, plc0002, plc0001; dims=1))

    if !(resolution in all_valid_values)
        valid_values_str = array_to_str(all_valid_values)
        error("""resolution voltage value of "$resolution" is not valid!
            It's voltage value must be one of:
            $(valid_values_str).""")
    end
end

function array_to_str(vs::AbstractArray)
    array_str = "["
    for v in vs
        push!(array_str, "$v,")
    end
    push!(array_str, "]")
    return array_str
end

verify_resolution_and_range(resolution::Unitful.Voltage, range::String) = error("Resolution cannot be set while range is set to \"AUTO\".")
verify_resolution_and_range(resolution, range) = nothing

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

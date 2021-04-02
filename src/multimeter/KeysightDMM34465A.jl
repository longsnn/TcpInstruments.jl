"""
# Available functions
- `initialize`
- `terminate`
- `get_tc_temperature` (tc = thermocouple)
- `get_voltage`
- `get_current`
- `get_resistance(;wire)` # wire must be set to 2 or 4
- `get_channel` # (some kind of input detection not selection)
"""
struct KeysightDMM34465A <: MultiMeter end

"""
    get_tc_temperature(multimeter)

Perform take a measurement with the probe mode set to thermocouple
"""
get_tc_temperature(obj::Instr{KeysightDMM34465A}) =
    f_query(obj, "MEASURE:TEMPERATURE? TC"; timeout=0)

"""
    set_tc_type(multimeter; type="K")

# Keywords
- `type`: Can be E, J, K, N, R, T (Defaults to K)
"""
function set_tc_type(obj::Instr{KeysightDMM34465A}; type="K")
    if !(string(type) in ["E", "J", "K", "N", "R", "T"])
        error("$type must be one of [E, J, K, N, R, T]")
    end
    write(obj, "CONFIGURE:TEMPERATURE TC,$type")
end

"""
Returns voltage

# Keywords
- `type`: "DC" | "AC" (Default DC)

"""
function get_voltage(obj::Instr{KeysightDMM34465A}; type="DC")
    !(type in ["AC","DC"]) && error("$type not valid!\nMust be AC or DC")
    f_query(obj, "MEASURE:VOLTAGE:$type?"; timeout=0)
end


"""
Returns current

# Keywords
- `type`: "DC" | "AC" (Default DC)

"""
function get_current(obj::Instr{KeysightDMM34465A}; type="DC")
    !(type in ["AC","DC"]) && error("$type not valid!\nMust be AC or DC")
    f_query(obj, "MEASURE:CURRENT:$type?"; timeout=0)
end

"""
    get_resistance(multimeter; wire=2)
    get_resistance(multimeter; wire=4)
Returns resistance

# Keywords
- `wire`: 2 | 4 (Required)

"""
function get_resistance(obj::Instr{KeysightDMM34465A}; wire)
    if wire == 2
        f_query(obj, "MEASURE:RESISTANCE?"; timeout=0)
    elseif wire == 4
        f_query(obj, "MEASURE:FRESISTANCE?"; timeout=0)
    else
        error("wire flag must be 2 or 4 not $wire")
    end
end

"""
    set_temp_unit_celsius(multimeter)

Sets the temperature unit to celcius
"""
set_temp_unit_celsius(obj::Instr{KeysightDMM34465A}) =
    write(obj, "UNIT:TEMPERATURE C")

"""
    set_temp_unit_farenheit(multimeter)

Sets the temperature unit to farenheit
"""
set_temp_unit_farenheit(obj::Instr{KeysightDMM34465A}) =
    write(obj, "UNIT:TEMPERATURE F")

"""
    set_temp_unit_kelvin(multimeter)

Sets the temperature unit to kelvin
"""
set_temp_unit_kelvin(obj::Instr{KeysightDMM34465A}) =
    write(obj, "UNIT:TEMPERATURE K")

"""
    get_temp_unit(multimeter)

Returns C, F or K depending on the set temperature unit
"""
get_temp_unit(obj::Instr{KeysightDMM34465A}) =
    query(obj, "UNIT:TEMPERATURE?")


"""
Indicates which input terminals are selected on the front panel
Front/Rear switch. This switch is not programmable; this query reports
the position of the switch, but cannot change it.

Do not toggle the Front/Rear switch with active signals on the
terminals. This switch is not intended to be used in this way and may be damaged by high voltages or currents, possibly compromising the
instrument's safety features.

# Returns
- "FRON" or "REAR"
"""
get_channel(obj::Instr{KeysightDMM34465A}) =
    query(obj, "ROUTE:TERMINALS?")

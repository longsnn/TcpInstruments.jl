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

Returns the voltage from the multimeter.

### Input

- `instr`
        initialized DMM object
- `type`
        Valid string values:
        "DC" | "AC" (Default DC)
- `range`
        Valid string values:
        "0.1" | "1" | "10" | "100" | "1000" | "AUTO" (Default AUTO)
- `PLC`
        Valid string values:
        "0.001" | "0.002" | "0.006" | "0.02" | "0.06" | "0.2" | "1" | "10" | "100" (Default 0.001)

See the manual for the allowed combinations

### Output

A single Float64 with unit of volt (from Unitful package).

"""
function get_voltage(
        instr::Instr{<:KeysightMultimeter}, # DMM Instrument
        type::String ="DC",       #   Voltage Type: "AC" or "DC"
        range::String = "AUTO",   #   Voltage Range: 0.1 to 1000 V
        plc::String = "0.001"          #   PLC: 0.001 to 100
    )

    # Check if voltage type is valid
    if !( type in ["AC", "DC"] )
        error("Voltage type \"$type\" is not valid!")
    end

    # Check if voltage range is valid
    if !( range in ["0.1", "1", "10", "100", "100", "1000", "AUTO"] )
        error("Voltage range \"$range\" is not valid!")
    end

    # Check if voltage plc is valid
    if !( plc in ["0.001", "0.002","0.006", "0.02", "0.06", "0.2", "1", "10", "100"] )
        error("Voltage plc \"$plc\" is not valid!")
    end

    # Get voltage measurement from DMM
    if range == "AUTO"
        # Auto-range does not accept resolution input
        f_query(instr, "MEASURE:VOLTAGE:$type? $range "; timeout=0) * V
    else
        # Get voltage resolution corresponding to range and plc
        resolution = _get_resolution(range, plc)
        # DMM voltage command accepts type, range, resolution as parameters
        f_query(instr, "MEASURE:VOLTAGE:$type? $range, $resolution "; timeout=0) * V
    end
end

"""
This is an internal function used by get_voltage

Returns the voltage resolution from table on page 453 in "Keysight Truevolt Series Operating and Service Guide"

Resolution Table for Keysight DMM 34465A:
        PLC 100	     10	     1	    0.2	    0.06	0.02	0.006	0.002	0.001
Range(V)
0.1		    3e-9	1e-8	3e-8	7e-8	1.5e-7	3e-7	6e-7	15e-7	30e-8
1	      	3e-8	1e-7	3e-7	7e-7	1.5e-6	3e-6	6e-6	15e-6	30e-7
10		    3e-7	1e-6	3e-6	7e-6	1.5e-5	3e-5	6e-5	15e-5	30e-6
100		    3e-6	1e-5	3e-5	7e-5	1.5e-4	3e-4	6e-4	15e-4	30e-5
1000 		3e-5	1e-4	3e-4	7e-4	1.5e-3	3e-3	6e-3	15e-3	30e-4

"""
function _get_resolution(range,plc::String)
    # Valid values taken from page 453 in "Keysight Truevolt Series Operating and Service Guide"
    # This assumes Keysight DMM 34465A

    # Range table used to get resolution table range index
    range_table = ["0.1","1","10","100","1000"]
    # PLC table used to get resolution table plc index
    plc_table = ["100", "10", "1", "0.2", "0.06", "0.02", "0.006", "0.002", "0.001"]

    # Resolution table used to get resolution using range as row, plc and column
                     #plc 1000     10      1       0.2     0.06     0.02    0.006   0.002    0.001
    resolution_table = [                                                                              # Range [V}
                        ["3e-9", "1e-8", "3e-8", "7e-8", "1.5e-7", "3e-7", "6e-7", "15e-7", "30e-8"], # 0.1
                        ["3e-8", "1e-7", "3e-7", "7e-7", "1.5e-6", "3e-6", "6e-6", "15e-6", "30e-7"], # 1
                        ["3e-7", "1e-6", "3e-6", "7e-6", "1.5e-5", "3e-5", "6e-5", "15e-5", "30e-6"], # 10
                        ["3e-6", "1e-5", "3e-5", "7e-5", "1.5e-4", "3e-4", "6e-4", "15e-4", "30e-5"], # 100
                        ["3e-5", "1e-4", "3e-4", "7e-4", "1.5e-3", "3e-3", "6e-3", "15e-3", "30e-4"]  # 1000
                        ]

    # get range index
    range_idx = findfirst( x -> x == range, range_table)
    #get PLC index
    plc_idx = findfirst( x -> x == plc, plc_table)

    # return resolution
    resolution = resolution_table[range_idx][plc_idx]

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

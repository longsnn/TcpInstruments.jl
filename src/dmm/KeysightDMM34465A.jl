"""
# Available functions
- initialize()
- terminate()
- get_tc_temperature() # tc = thermocouple
- set_tc_type()
- get_volt()
- get_amp()
"""
struct KeysightDMM34465A <: MultiMeter end

"""
Page. 288
<probe_type>: {FRTD|RTD|FTHermistor|THERmistor|TCouple}. Default: FRTD. (none)

<type>: 85 (only possible value for RTD/FRTD), 5000 (only possible value for THERmis-
tor/FTHermistor), or E, J, K, N, R, T (TCouple).

<resolution>: See Resolution Table or Range, Resolution and NPLC. The
default is equivalent to 10 PLC.

"""
get_tc_temperature(obj::Instr{KeysightDMM34465A}; probe="TC" ) =
    query(obj, "MEAS:TEMP? TC") # TODO: Resolution adujstable if neccessary/Change probe

# TODO: Implement
set_tc_type(obj::Instr{KeysightDMM34465A}) = udef(@codeLocation)

"""

# Arguments
- `type`: "DC" | "AC"

"""
function get_volt(obj::Instr{KeysightDMM34465A}; type="DC")
    if !type in ["AC","DC"]
        error("$type not valid!\nMust be AC or DC")
    end
    query(obj, "MEAS:VOLT:$type?")
end

get_amp(obj::Instr{KeysightDMM34465A}) =

set_temp_celsius(obj::Instr{KeysightDMM34465A}) =
    write(obj, "UNIT:TEMP C")

set_temp_farenheit(obj::Instr{KeysightDMM34465A}) =
    write(obj, "UNIT:TEMP F")

set_temp_kelvin(obj::Instr{KeysightDMM34465A}) =
    write(obj, "UNIT:TEMP K")


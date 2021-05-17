"""
    SRSPS310
    GPIB Enabled Device. Requires an attached Prologix Controller to work.


# Available functions
- `enable_output()`
- `disable_output()`
- `set_voltage(volts)`
- `get_voltage()`
- `set_voltage_limit(volts)`
- `get_voltage_limit()`
- `set_current_limit(current)`
- `get_current_limit()`
- `set_prologix_chan(chan)`
- `get_prologix_chan(chan)`
"""
struct SRSPS310 <: PowerSupply end


"""
This will enable an output on a device.

Arguments:
  - obj
    - must be a Power Supply Instrument
Supported Instruments:
   - Power supply
"""
enable_output(obj::Instr{SRSPS310}) = write(obj, "HVON")

"""
This will disable an output on a device.

Arguments:
  - obj
    - must be a Power Supply Instrument
Supported Instruments:
   - Power supply
"""
disable_output(obj::Instr{SRSPS310}) = write(obj, "HVOF")

"""
This will get and return the output from a device.

Arguments:
  - obj
    - must be a Power Supply Instrument
Supported Instruments:
   - Power supply

# Returns
- true if High Voltage Output is Off
- false if High Voltage Output is On
"""
get_output(obj::Instr{SRSPS310}) = query(obj, "*STB? 7") == "1" ? true : false

"""
This will change the voltage output of a device.

To see the (adjustable) voltage limit the the function `get_voltage_limit(instr)`

Supported Instruments:
   - Power supply

Returns:
  Nothing
"""
set_voltage(obj::Instr{SRSPS310}, num) = write(obj, "VSET$(Float64(num))")

"""
This will return the voltage of a device

Voltage Limit: 1250V

Supported Instruments:
   - Power supply

Returns:
  Voltage
"""
get_voltage(obj::Instr{SRSPS310}) = f_query(obj, "VSET?") # VLIM?

"""
    set_voltage_limit(::SRSPS310, voltage_limit)

This will change the voltage limit of a device.

Max Voltage Limit: 1250V

Supported Instruments:
   - Power supply

Returns:
  Nothing
"""
set_voltage_limit(obj::Instr{SRSPS310}, num) = write(obj, "VLIM$(Float64(num))")

"""
This will return the voltage limit of a device

Voltage Limit: 1250V

Supported Instruments:
   - Power supply

Returns:
  Voltage
"""
get_voltage_limit(obj::Instr{SRSPS310}) = f_query(obj, "VLIM?") # VLIM?

"""
This will change the current limit of a device

MIN Value: 0
Max Value: { 2.1e-3 | 0.021 } (21mA)

Supported Instruments:
   - Power supply

Returns:
  Nothing
"""
set_current_limit(obj::Instr{SRSPS310}, num) = write(obj, "ILIM$(Float64(num))")

"""
This will return the current limit of a device.


Supported Instruments:
   - Power supply

Returns:
  Current Limit
"""
get_current_limit(obj::Instr{SRSPS310}) = f_query(obj, "ILIM?")

function scan_prologix(obj::Instr{SRSPS310})
    devices = Dict()
    for i in 0:15
        write(obj, "++addr $i")
        try
            devices[i] = query(obj, "*IDN?"; timeout=0.5)
        catch

        end
    end
    return devices
end

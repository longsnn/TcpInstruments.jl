"""
    enable_output(obj::Instr{<:VersatilePowerSupply})

This will enable an output on a device.

Arguments:
  - obj
    - must be a Power Supply Instrument
Supported Instruments:
   - Power supply
"""
enable_output(obj::Instr{<:VersatilePowerSupply}) = write(obj, "OUTPUT ON")

"""
    disable_output(obj::Instr{<:VersatilePowerSupply})

This will disable an output on a device.

Arguments:
  - obj
    - must be a Power Supply Instrument
Supported Instruments:
   - Power supply
"""
disable_output(obj::Instr{<:VersatilePowerSupply}) = write(obj, "OUTPUT OFF")


"""
    get_output(obj::Instr{<:VersatilePowerSupply})

This will return the state of an output on a device.

Arguments:
  - obj
    - must be a Power Supply Instrument
Supported Instruments:
   - Power supply

Returns:
  String: {"OFF"|"ON"}
"""
get_output(obj::Instr{<:VersatilePowerSupply}) = query(obj, "OUTPUT?")

"""
    set_voltage(obj::Instr{<:VersatilePowerSupply}, num::Voltage)

This will change the voltage output of a device.


Supported Instruments:
   - Power supply

Returns:
  Nothing
"""
set_voltage(obj::Instr{<:VersatilePowerSupply}, num::Voltage) = write(obj, "VOLTAGE $(raw(num))")

"""
    get_voltage(obj::Instr{<:VersatilePowerSupply})

This will return the voltage of a device

Supported Instruments:
   - Power supply

Returns:
  Voltage
"""
get_voltage(obj::Instr{<:VersatilePowerSupply}) = f_query(obj, "VOLTAGE?") * V

"""
    set_current_limit(obj::Instr{<:VersatilePowerSupply}, num::Current)

This will change the current limit of a device

Supported Instruments:
   - Power supply

Returns:
  Nothing
"""
set_current_limit(obj::Instr{<:VersatilePowerSupply}, num::Current) = write(obj, "CURRENT $(raw(num))")

"""
    get_current_limit(obj::Instr{<:VersatilePowerSupply})

This will return the current limit of a device.


Supported Instruments:
   - Power supply

Returns:
  Current Limit
"""
get_current_limit(obj::Instr{<:VersatilePowerSupply}) = query(obj, "CURRENT?")


"""
    remote_mode(obj::Instr{<:VersatilePowerSupply})

Set device to remote mode
"""
remote_mode(obj::Instr{<:VersatilePowerSupply}) = write(obj, "SYSTEM:MODE REMOTE")

"""
    local_mode(obj::Instr{<:VersatilePowerSupply})

Set device to remote mode
"""
local_mode(obj::Instr{<:VersatilePowerSupply}) =   write(obj, "SYSTEM:MODE LOCAL")

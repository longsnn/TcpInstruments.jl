"""
This device only has one channel so channel specific functions
and optional arguments are not available.

# Available functions
- [`enable_output(obj::Instr{VersatilePower})`](@ref)
- [`disable_output(obj::Instr{VersatilePower})`](@ref)
- [`set_voltage(obj::Instr{VersatilePower})`](@ref)
- [`get_voltage(obj::Instr{VersatilePower})`](@ref)
- [`set_current_limit(obj::Instr{VersatilePower}, current)`](@ref)
- [`get_current_limit(obj::Instr{VersatilePower})`](@ref)

# Helpers
- `remote_mode()`: sets the device to remote mode. Automatically called on initialize
- `local_mode()`: sets the device to local mode. Automatically called on terminate

This instrument has a remote and local mode. Some commands do not
work while the device is in local mode, thus when initializing this
device `remote_mode` is called automatically and the device is always in
remote mode by default.

These functions should not be directly needed but if
for some reason you need to switch modes while using the device
you can use `local_mode` to turn the device back to
local mode.

"""
struct VersatilePower <: PowerSupply end


"""
    enable_output(obj::Instr{VersatilePower})

This will enable an output on a device.

Arguments:
  - obj
    - must be a Power Supply Instrument
Supported Instruments:
   - Power supply
"""
enable_output(obj::Instr{VersatilePower}) = write(obj, "OUTPUT ON")

"""
    disable_output(obj::Instr{VersatilePower})

This will disable an output on a device.

Arguments:
  - obj
    - must be a Power Supply Instrument
Supported Instruments:
   - Power supply
"""
disable_output(obj::Instr{VersatilePower}) = write(obj, "OUTPUT OFF")


"""
    get_output(obj::Instr{VersatilePower})

This will return the state of an output on a device.

Arguments:
  - obj
    - must be a Power Supply Instrument
Supported Instruments:
   - Power supply

Returns:
  String: {"OFF"|"ON"}
"""
get_output(obj::Instr{VersatilePower}) = query(obj, "OUTPUT?")

"""
    set_voltage(obj::Instr{VersatilePower}, num::Voltage)

This will change the voltage output of a device.


Supported Instruments:
   - Power supply

Returns:
  Nothing
"""
set_voltage(obj::Instr{VersatilePower}, num::Voltage) = write(obj, "VOLTAGE $(raw(num))")

"""
    get_voltage(obj::Instr{VersatilePower})

This will return the voltage of a device

Supported Instruments:
   - Power supply

Returns:
  Voltage
"""
get_voltage(obj::Instr{VersatilePower}) = f_query(obj, "VOLTAGE?") * V

"""
    set_current_limit(obj::Instr{VersatilePower}, num::Current)

This will change the current limit of a device

Supported Instruments:
   - Power supply

Returns:
  Nothing
"""
set_current_limit(obj::Instr{VersatilePower}, num::Current) = write(obj, "CURRENT $(raw(num))")

"""
    get_current_limit(obj::Instr{VersatilePower})

This will return the current limit of a device.


Supported Instruments:
   - Power supply

Returns:
  Current Limit
"""
get_current_limit(obj::Instr{VersatilePower}) = query(obj, "CURRENT?")


"""
    remote_mode(obj::Instr{VersatilePower})

Set device to remote mode
"""
remote_mode(obj::Instr{VersatilePower}) = write(obj, "SYSTEM:MODE REMOTE")

"""
    local_mode(obj::Instr{VersatilePower})

Set device to remote mode
"""
local_mode(obj::Instr{VersatilePower}) =   write(obj, "SYSTEM:MODE LOCAL")

"""
This device only has one channel so channel specific functions
and optional arguments are not available.

# Available functions
- enable_output()
- disable_output()
- set_voltage(volts)
- get_voltage()
- set_current_limit(current)
- get_current_limit()

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
struct VersatilePowerBench100_10XR <: PowerSupply end


"""
This will enable an output on a device.

Arguments:
  - obj
    - must be a Power Supply Instrument
Supported Instruments:
   - Power supply
"""
enable_output(obj::Instr{VersatilePowerBench100_10XR}) = write(obj, "OUTPUT ON")

"""
This will disable an output on a device.

Arguments:
  - obj
    - must be a Power Supply Instrument
Supported Instruments:
   - Power supply
"""
disable_output(obj::Instr{VersatilePowerBench100_10XR}) = write(obj, "OUTPUT OFF")


"""
This will return the state of an output on a device.

Arguments:
  - obj
    - must be a Power Supply Instrument
Supported Instruments:
   - Power supply

Returns:
  String: {"OFF"|"ON"}
"""
get_output(obj::Instr{VersatilePowerBench100_10XR}) = query(obj, "OUTPUT?")

"""
This will change the voltage output of a device.


Supported Instruments:
   - Power supply

Returns:
  Nothing
"""
set_voltage(obj::Instr{VersatilePowerBench100_10XR}, num) = write(obj, "VOLTAGE $num")

"""
This will return the voltage of a device

Supported Instruments:
   - Power supply

Returns:
  Voltage
"""
get_voltage(obj::Instr{VersatilePowerBench100_10XR}) = query(obj, "VOLTAGE?")

"""
This will change the current limit of a device 

Supported Instruments:
   - Power supply

Returns:
  Nothing
"""
set_current_limit(obj::Instr{VersatilePowerBench100_10XR}, num) = write(obj, "CURRENT $num")

"""
This will return the current limit of a device.


Supported Instruments:
   - Power supply

Returns:
  Current Limit
"""
get_current_limit(obj::Instr{VersatilePowerBench100_10XR}) = query(obj, "CURRENT?")


remote_mode(obj::Instr{VersatilePowerBench100_10XR}) = write(obj, "SYSTEM:MODE REMOTE")

local_mode(obj::Instr{VersatilePowerBench100_10XR}) =   write(obj, "SYSTEM:MODE LOCAL")

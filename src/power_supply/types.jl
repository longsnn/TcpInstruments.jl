"""
- [`AgilentPowerSupply`](@ref)
- [`SRSPowerSupply`](@ref)
- [`VersatilePowerSupply`](@ref)
"""
abstract type PowerSupply <: Instrument end


"""
Supported models
- `AgilentE36312A`

Supported functions
- [`initialize`](@ref)
- [`terminate`](@ref)


- [`get_output`](@ref)
- [`enable_output`](@ref)
- [`disable_output`](@ref)
- [`get_channel`](@ref)
- [`set_channel`](@ref)
- [`get_voltage`](@ref)
- [`set_voltage`](@ref)
- [`get_current_limit`](@ref)
- [`set_current_limit`](@ref)
"""
abstract type AgilentPowerSupply <: PowerSupply end
struct AgilentE36312A <: AgilentPowerSupply end


"""
Supported models
- `SRSPS310` (GPIB enabled device. Requires an attached Prologix Controller to work)

Supported functions
- [`initialize`](@ref)
- [`terminate`](@ref)


- [`get_output`](@ref)
- [`enable_output`](@ref)
- [`disable_output`](@ref)
- [`get_voltage`](@ref)
- [`set_voltage`](@ref)
- [`get_voltage_limit`](@ref)
- [`set_voltage_limit`](@ref)
- [`get_current_limit`](@ref)
- [`set_current_limit`](@ref)
"""
abstract type SRSPowerSupply <: PowerSupply end
struct SRSPS310 <: SRSPowerSupply end


abstract type VersatilePowerSupply <: PowerSupply end
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
struct Versatile2005XRLXI <: VersatilePowerSupply end
struct Versatile10010XRLXI <: VersatilePowerSupply end

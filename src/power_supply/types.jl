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


- [`get_output_status`](@ref)
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


- [`get_output_status`](@ref)
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


"""
Supported models
- `Versatile2005XRLXI` (single channel)
- `Versatile10010XRLXI` (single channel)

Supported functions
- [`initialize`](@ref)
- [`terminate`](@ref)


- [`get_output_status`](@ref)
- [`enable_output`](@ref)
- [`disable_output`](@ref)
- [`get_voltage`](@ref)
- [`set_voltage`](@ref)
- [`get_current_limit`](@ref)
- [`set_current_limit`](@ref)


- [`remote_mode`](@ref) (automatically called by [`initialize`](@ref))
- [`local_mode`](@ref) (automatically called by [`terminate`](@ref))

This instrument has a remote mode and a local mode. Some commands do not
work while the device is in local mode, therefore [`remote_mode`](@ref) 
is called automatically upon initialization. By default, the device is 
always in remote mode.

These functions should not be directly needed but if
for some reason you need to switch modes while using the device
you can use [`local_mode`](@ref) to turn the device back to
local mode.
"""
abstract type VersatilePowerSupply <: PowerSupply end
struct Versatile2005XRLXI <: VersatilePowerSupply end
struct Versatile10010XRLXI <: VersatilePowerSupply end

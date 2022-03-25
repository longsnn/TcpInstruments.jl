"""
- [`AgilentPowerSupply`](@ref)
- [`SRSPowerSupply`](@ref)
- [`VersatilePowerSupply`](@ref)
"""
abstract type PowerSupply <: Instrument end

abstract type AgilentPowerSupply <: PowerSupply end
"""
Supported functions
- `enable_output()`
- `disable_output()`
- `set_voltage(voltage)`
- `get_voltage()`
- `set_current_limit(current)`
- `get_current_limit()`
- `set_channel(channel)`
- `get_channel()`
"""
struct AgilentE36312A <: AgilentPowerSupply end

abstract type SRSPowerSupply <: PowerSupply end
abstract type VersatilePowerSupply <: PowerSupply end

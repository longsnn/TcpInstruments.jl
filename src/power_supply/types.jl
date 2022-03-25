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


abstract type SRSPowerSupply <: PowerSupply end
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
struct SRSPS310 <: SRSPowerSupply end

abstract type VersatilePowerSupply <: PowerSupply end

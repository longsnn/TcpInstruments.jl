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

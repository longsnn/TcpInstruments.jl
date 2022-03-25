"""
- [`AgilentPowerSupply`](@ref)
- [`SRSPowerSupply`](@ref)
- [`VersatilePowerSupply`](@ref)
"""
abstract type PowerSupply <: Instrument end

abstract type AgilentPowerSupply <: PowerSupply end
abstract type SRSPowerSupply <: PowerSupply end
abstract type VersatilePowerSupply <: PowerSupply end

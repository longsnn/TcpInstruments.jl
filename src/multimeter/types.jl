"""
- [`KeysightMultimeter`](@ref)
"""
abstract type MultiMeter <: Instrument end

abstract type KeysightMultimeter <: MultiMeter end
"""
# Available functions
- `initialize`
- `terminate`
- `get_tc_temperature` (tc = thermocouple)
- `get_voltage`
- `get_current`
- `get_resistance(;wire)` # wire must be set to 2 or 4
- `get_channel` # (some kind of input detection not selection)
"""
struct KeysightDMM34465A <: KeysightMultimeter end

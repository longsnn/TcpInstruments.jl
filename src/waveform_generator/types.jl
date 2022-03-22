"""
- [`Keysight33612A`](@ref)
"""
abstract type WaveformGenerator <: Instrument end

abstract type KeysightWaveGen <: WaveformGenerator end
struct Keysight33612A <: KeysightWaveGen end

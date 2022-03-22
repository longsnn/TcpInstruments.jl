"""
- [`Keysight33612A`](@ref)
"""
abstract type WaveformGenerator <: Instrument end

abstract type KeysightWaveformGenerator <: WaveformGenerator end
struct Keysight33612A <: KeysightWaveformGenerator end

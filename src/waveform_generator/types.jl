"""
- [`KeysightWaveGen`](@ref)
"""
abstract type WaveformGenerator <: Instrument end


"""
Supported functions
- [`initialize`](@ref)
- [`terminate`](@ref)


- [`get_output_status`](@ref)
- [`set_output_on`](@ref)
- [`set_output_off`](@ref)
- [`get_frequency`](@ref)
- [`set_frequency`](@ref)
- [`get_amplitude`](@ref)
- [`set_amplitude`](@ref)
- [`get_voltage_offset`](@ref)
- [`set_voltage_offset`](@ref)


- [`get_function`](@ref)
- [`set_function`](@ref)


- [`get_mode`](@ref)
- [`set_mode_cw`](@ref)
- [`set_mode_burst`](@ref)
- [`get_burst_mode`](@ref)
- [`set_burst_mode_trigger`](@ref)
- [`set_burst_mode_gated`](@ref)
- [`get_burst_num_cycles`](@ref)
- [`set_burst_num_cycles`](@ref)
- [`get_burst_period`](@ref)
- [`set_burst_period`](@ref)

Not yet implemented
- `get_time_offset`
- `set_time_offset`

Example for creating a sin wave:
```
wg = initialize(Keysight33612A, [ip_address])
set_mode_cw(wg)
set_function(wg, "SIN")
set_frequency(wg, 1u"kHz")
set_amplitude(wg, 0.1u"V")
set_voltage_offset(wg, 0u"V")
set_output_on(wg)
```
"""
abstract type KeysightWaveGen <: WaveformGenerator end
struct Keysight33612A <: KeysightWaveGen end

"""
Device has two channels: 1 & 2
# Supported functions
- `initialize()`
- `terminate()`
- `enable_output()`
- `disable_output()`
- `get_output()`
- `get_frequency()`
- `set_frequency()`
- `get_amplitude()`
- `set_amplitude()`
- `get_burst_num_cycles()`
- `set_burst_num_cycles()`
- `get_time_offset()`: Not implemented
- `set_time_offset()`: Not implemented
- `get_voltage_offset()`
- `set_voltage_offset()`
- `get_burst_period()`
- `set_burst_period()`
- `get_mode()`
- `set_mode_burst(; mode=:trigger, trig_src=:timer)`
- `set_mode_cw()`

Creating a Sin Wave Example:
```
wave = initialize(Keysight33612A, "10.1.30.36")
set_mode_cw(wave) # Set to continuous waveform mode
set_function(wave, "SIN")
set_frequency(wave, "1e3") # Frequency val can be string or number
set_amplitude(wave, 0.1)
set_voltage_offset(wave, 0)
enable_output(wave) # Starts wave
```
"""
struct Keysight33612A <: WaveformGenerator end
#instrument_reset(obj::Instr{AgilentDSOX4024A})    = write(obj, "*RST for 402")

get_voltage_offset(obj::Instr{Keysight33612A}; chan=1) =
    f_query(obj, "SOURCE$chan:VOLTAGE:OFFSET?")
set_voltage_offset(obj::Instr{Keysight33612A}, num; chan=1) =
    write(obj, "SOUR$chan:VOLTAGE:OFFSET $num")

get_amplitude(obj::Instr{Keysight33612A}; chan=1) =
    f_query(obj, "SOUR$chan:VOLTAGE?")
SET_AMPLITUDE(obj::Instr{Keysight33612A}, num; chan=1) =
    write(obj, "SOUR$chan:VOLTAGE $num")


get_frequency(obj::Instr{Keysight33612A}; chan=1) =
    f_query(obj, "SOUR$chan:FREQUENCY?") # +4.0E+05
set_frequency(obj::Instr{Keysight33612A}, num; chan=1) =
    write(obj, "SOUR$chan:FREQUENCY $num") # +4.0E+05

get_function(obj::Instr{Keysight33612A}; chan=1) =
    query(obj, "SOUR$chan:FUNCTION?") # +4.0E+05

"""
Acceptable inputs
{SINusoid|SQUare|TRIangle|RAMP|PULSe|PRBS|NOISe|ARB|DC}
"""
set_function(obj::Instr{Keysight33612A}, func; chan=1) = write(obj, "SOUR$chan:FUNCTION $func") # +4.0E+05

"""
    Sets the burst mode of a device to Triggered Mode

"""
set_burst_mode_trigger(obj::Instr{Keysight33612A}; chan=1) =
    write(obj, "SOUR$chan:BURST:MODE TRIG")
"""
    Sets the burst mode of a device to Gated Mode

"""
set_burst_mode_gated(obj::Instr{Keysight33612A}; chan=1) =
    write(obj, "SOUR$chan:BURST:MODE GATED")

"""


    Returns the burst mode of a device:
        "TRIG" ~ If the device is in Triggered Mode
        "GAT" ~ If the device is in Gated Mode
"""
get_burst_mode(obj::Instr{Keysight33612A}; chan=1) =
    query(obj, "SOUR$chan:BURST:MODE?")

"""
```
    set_mode_burst(instr)
```
Changes Waveform Generator mode from continous waveform to burst

By default it sets the type of burst mode to triggered mode. Gated
mode can also be set by using the optional flag:

```
    set_mode_burst(instr; mode=:gated)
```

The optional trig_src flag sets the trigger source for burst
triggered mode. Right now the default is Timer. To implement
more trigger sources see page 130 of the manual for 33612A

"""
function set_mode_burst(obj::Instr{Keysight33612A}; 
                         chan=1,
                         mode=:trigger,
                         trig_src=:timer)
    if mode == :trigger
        set_burst_mode_trigger(obj)
    elseif mode == :gated
        set_burst_mode_gated(obj)
    else
        error("""mode flag cannot be set to: $mode\n 
              available modes are [:trigger, :gated]""")
    end
    if trig_src == :timer
        set_trigger_source_timer(obj; chan=chan)
    else
        error("""trig_src flag cannot be set to: $trig_src\n 
              available modes are [:timer]""")
    end
    write(obj, "SOURCE$chan:BURST:STATE ON")
end

"""
Puts the device in continuous waveform/turns off burst mode

"""
set_mode_cw(obj::Instr{Keysight33612A}; chan=1) =
    write(obj, "SOURCE$chan:BURST:STATE OFF")

"""
Returns:
    "CW" ~ if device is in continous wavefrom mode
    "BURST" ~ if device is in BURST mode
"""
get_mode(obj::Instr{Keysight33612A}; chan=1) =
    query(obj, "SOURCE$chan:BURST:STATE?") == "1" ? "BURST" : "CW"

"""
Returns number of cycles burst mode is set to
"""
get_burst_num_of_cycles(obj::Instr{Keysight33612A}; chan=1) =
    write(obj, "SOURCE$chan:BURST:NCYCLES?")

"""
Sets the number of cycles for burst mode
"""
set_burst_num_of_cycles(obj::Instr{Keysight33612A}, num; chan=1) =
    write(obj, "SOURCE$chan:BURST:NCYCLES $num")

"""
chan=<1|2>

num = {<seconds>|MINimum|MAXimum}
"""
set_burst_period(obj, num; chan=1) =
    write(obj, "SOURCE$chan:BURST:INTERNAL:PERIOD $num")

get_burst_period(obj; chan=1) =
    write(obj, "SOURCE$chan:BURST:INTERNAL:PERIOD?")

set_trigger_source_timer(obj; chan=1) = 
    write(obj, "TRIGGER$chan:SOURCE TIMER")


status(obj::Instr{Keysight33612A}) = write(obj, "APPLY?")


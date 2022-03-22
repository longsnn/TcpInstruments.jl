"""
Device has two channels: 1 & 2
# Supported functions
- `initialize()`
- `terminate()`
- `set_output_on()`
- `set_output_off()`
- `get_output_status()`
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

set_output_on(obj::Instr{Keysight33612A}; chan=1) = write(obj, "OUTPUT$chan ON")
set_output_off(obj::Instr{Keysight33612A}; chan=1) = write(obj, "OUTPUT$chan OFF")
function get_output_status(obj::Instr{Keysight33612A}; chan=1) 
    return query(obj, "OUTPUT$chan?") == "1" ? "ON" : "OFF"
end


get_voltage_offset(obj::Instr{Keysight33612A}; chan=1) =
    f_query(obj, "SOURCE$chan:VOLTAGE:OFFSET?") * V
set_voltage_offset(obj::Instr{Keysight33612A}, num::Voltage; chan=1) =
    write(obj, "SOURCE$chan:VOLTAGE:OFFSET $(raw(num))")

get_amplitude(obj::Instr{Keysight33612A}; chan=1) =
    f_query(obj, "SOURCE$chan:VOLTAGE?") * V
set_amplitude(obj::Instr{Keysight33612A}, num::Voltage; chan=1) =
    write(obj, "SOURCE$chan:VOLTAGE $(raw(num))")


get_frequency(obj::Instr{Keysight33612A}; chan=1) =
    f_query(obj, "SOURCE$chan:FREQUENCY?")
set_frequency(obj::Instr{Keysight33612A}, num::Frequency; chan=1) =
    write(obj, "SOURCE$chan:FREQUENCY $(raw(num))")

"""
    get_function(instr)
    get_function(instr; chan=2)

# Keywords
- `chan`: Specify channel: Default is 1
# Returns
- `String`: Will return one of these shortened forms:
{SINusoid|SQUare|TRIangle|RAMP|PULSe|PRBS|NOISe|ARB|DC}
"""
get_function(obj::Instr{Keysight33612A}; chan=1) = query(obj, "SOURCE$chan:FUNCTION?") # +4.0E+05

"""
set_function(instr, func; chan=1)

# Arguments
- `func::String`: Acceptable inputs:
{SINusoid|SQUare|TRIangle|RAMP|PULSe|PRBS|NOISe|ARB|DC}

# Keywords
- `chan`: Specify channel: Default is 1
"""
set_function(obj::Instr{Keysight33612A}, func; chan=1) = write(obj, "SOURCE$chan:FUNCTION $func") # +4.0E+05

"""
    Sets the burst mode of a device to Triggered Mode

"""
set_burst_mode_trigger(obj::Instr{Keysight33612A}; chan=1) = write(obj, "SOURCE$chan:BURST:MODE TRIG")
"""
Sets the burst mode of a device to Gated Mode
"""
set_burst_mode_gated(obj::Instr{Keysight33612A}; chan=1) = write(obj, "SOURCE$chan:BURST:MODE GATED")

"""
    get_burst_mode(instr)
    get_burst_mode(instr; chan=1)

Returns the burst mode of a device:
    "TRIG" ~ If the device is in Triggered Mode
    "GAT" ~ If the device is in Gated Mode
"""
get_burst_mode(obj::Instr{Keysight33612A}; chan=1) = query(obj, "SOURCE$chan:BURST:MODE?")

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
set_mode_cw(instr)
set_mode_cw(instr; chan=2)

Puts the device in continuous waveform/turns off burst mode

# Keywords
- `chan`: Specify channel: Default is 1
"""
set_mode_cw(obj::Instr{Keysight33612A}; chan=1) = write(obj, "SOURCE$chan:BURST:STATE OFF")

"""
    get_mode(instr)
    get_mode(instr; chan=2)

# Keywords
- `chan`: Specify channel: Default is 1
Returns:
    "CW" ~ if device is in continous wavefrom mode
    "BURST" ~ if device is in BURST mode
"""
get_mode(obj::Instr{Keysight33612A}; chan=1) = query(obj, "SOURCE$chan:BURST:STATE?") == "1" ? "BURST" : "CW"

"""
    get_burst_num_of_cycles(instr)
    get_burst_num_of_cycles(instr; chan=2)

# Keywords
- `chan`: Specify channel: Default is 1

# Returns
- `Float64`: number of cycles burst mode is set to
"""
get_burst_num_cycles(obj::Instr{Keysight33612A}; chan=1) = f_query(obj, "SOURCE$chan:BURST:NCYCLES?")

"""
    set_burst_num_of_cycles(instr, cycles)
    set_burst_num_of_cycles(instr, cycles; chan=2)

Sets the number of cycles for burst mode

# Arguments
- `cycles`
# Keywords
- `chan`: Specify channel: Default is 1
"""
set_burst_num_cycles(obj::Instr{Keysight33612A}, num; chan=1) = write(obj, "SOURCE$chan:BURST:NCYCLES $(Float64(num))")

"""
    set_burst_period(obj, num; chan=1)

# Arguments
- `num`: The number of seconds (This value can also be "MIN" or "MAX")
# Keywords
- `chan`: Specify channel: Default is 1
"""
set_burst_period(obj::Instr{Keysight33612A}, num; chan::Integer=1) = write(obj, "SOURCE$chan:BURST:INTERNAL:PERIOD $(Float64(num))")

"""
    get_burst_period(instr)
    get_burst_period(instr; chan=1)

# Keywords
- `chan`: Specify channel: Default is 1
# Returns
- `Float64`: time between bursts [s]
"""
get_burst_period(obj::Instr{Keysight33612A}; chan::Integer=1) = f_query(obj, "SOURCE$chan:BURST:INTERNAL:PERIOD?") * s

set_trigger_source_timer(obj::Instr{Keysight33612A}; chan::Integer=1) = write(obj, "TRIGGER$chan:SOURCE TIMER")


status(obj::Instr{Keysight33612A}) = query(obj, "APPLY?")

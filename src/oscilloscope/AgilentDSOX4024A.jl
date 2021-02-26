"""
# Available Functions

- `initialize`
- `terminate`
- `get_data`
- `lpf_on`
- `lpf_off`
- `get_lpf_state`
- `set_impedance_1Mohm`
- `set_impedance_50ohm`
- `get_impedance`

# Example

```
> scope_h = initialize(AgilentDSOX4024A)
```

Grab data from channel 1
```
> data = get_data(scope_h, 1)
```

Grab data from channel 2 and 4
```
> data_array = get_data(scope_h, [2,4])
```

Grab data from all available channels
Plot waves from all available channels
```
> using Plots
> data_array = get_data(scope_h)
> plot(data_struct)
```

Low Pass Filter
Turn on Low Pass Filter 25
```
> lpf_on(scope)
```

Check if low pass filter is on
```
> get_lpf_state(scope) == "1"
```

Turn on Low Pass Filter 25MHz
```
> lpf_off(scope)
> get_lpf_state(scope) == "0"
```

Impedance

```
> set_impedance_1Mohm(scope_h)
> get_impedance(scope_h) == ONEM
> set_impedance_50ohm(scope_h)
> get_impedance(scope_h) == FIFT
```

Terminate TCP connection
```
> terminate(scope_h)
```
"""
struct AgilentDSOX4024A <: Oscilloscope end

"""
TcpInstruments is an ongoing effort to provide a simple unified
interface to common lab equipment.

To connect to an instrument use:
```
handle = initialize({Instrument-Type}, "IP-ADDRESS:PORT")
```

To prevent hardcoding in scripts and/or to make it simplier for
your lab or organization to keep track of all the equipment and
ip addresses a configuration file can also be specified.

To use Orchard Ultrasound's latest lab config use:
```
create_config()
```
This will create a yaml file in your home directory: ~/.tcp_instruments.yml

This yaml file will be loaded everytime you use this package.

You can also create a project-specific config by creating
the config in your project root directory instead of your home
directory. You can do this with:
```
create_config(pwd())
```

Once you have created a config file you can change it with
```
edit_config()
```

If the instrument has its address in the config file you can now connect with: 
```
handle = initialize({Instrument-Type})
```

To see the different types of devices you can interface with
use `help>Instrument`.
"""
module TcpInstruments

using Sockets
using Unitful

export Instrument
export Oscilloscope, MultiMeter, PowerSupply, WaveformGenerator, ImpedanceAnalyzer

export save, load

export initialize, terminate, reset,
export remote_mode, local_mode,
export query, write, info, connect!, close!

# Power Supply
export enable_output, disable_output, get_output
export set_current_limit, get_current_limit
export set_voltage, get_voltage
export set_voltage_limit, get_voltage_limit
export set_channel, get_channel

    # Scope
export get_data,
export lpf_on, lpf_off, get_lpf_state,
export set_impedance_1Mohm, set_impedance_50ohm, get_impedance
export get_coupling
export get_function, set_function
export get_frequency, set_frequency,
export get_amplitude, set_amplitude,
export get_voltage_offset, set_voltage_offset,
export set_burst_mode_gated, set_burst_mode_triggered, get_burst_mode
export get_mode, set_mode_burst, set_mode_cw,


# Prologix
export set_prologix_chan, get_prologix_chan, scan_prologix


# DMM
export get_tc_temperature, set_tc_type
export get_current,
export get_resistance,
export set_temp_unit_celsius, set_temp_unit_farenheit, set_temp_unit_kelvin,
export get_temp_unit,

# Impedance
export get_bandwidth, set_bandwidth,
export get_frequency_limits, set_frequency_limits,
export get_num_data_points, set_num_data_points,
export get_volt_dc, set_volt_dc,
export get_volt_ac, set_volt_ac,
export get_volt_limit_dc, set_volt_limit_dc,

# Signal Generator
export get_frequency, set_frequency,
export get_amplitude, set_amplitude,
export get_burst_num_cycles, set_burst_num_cycles,
export get_time_offset, set_time_offset,
export get_voltage_offset, set_voltage_offset,
export get_burst_period, set_burst_period,
export get_mode, set_mode_burst, set_mode_cw,



# Devices
## Impedance Analyzer
export Agilent4294A, Agilent4395A,
## Multimeter
export KeysightDMM34465A,
## Scope
export AgilentDSOX4024A, AgilentDSOX4034A,
## Power Supply
export AgilentE36312A, SRSPS310, VersatilePower
## Waveform Generator
export Keysight33612A

export scan_network

include("util.jl")
include("config.jl")

# common instrument containers
include("instr.jl")
include("instrument.jl")
include("common_commands.jl")

# instruments
include("oscilloscope/scope.jl")
include("power_supply/psu.jl")
include("signal_generator/awg.jl")
include("impedance_analyzer/ia.jl")
include("multimeter/dmm.jl")

end #endmodule

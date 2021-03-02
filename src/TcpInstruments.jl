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
This will create a yaml file in your home directory: ~/.tcp.yml

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

export 
    Instrument,
    Oscilloscope, 
    MultiMeter,
    PowerSupply,
    WaveformGenerator,
    ImpedanceAnalyzer,

    Configuration,
    create_aliases,
    create_config,
    edit_config,
    get_config,
    load_config,
    load_python,

    initialize,
    terminate,
    reset,
    connect!,
    close!,
    remote_mode,
    local_mode,
    query,
    write,
    info,


    # Power Supply
    enable_output,
    disable_output,
    get_output,
    set_current_limit,
    get_current_limit,
    set_voltage,
    get_voltage,
    set_voltage_limit,
    get_voltage_limit,
    set_channel,
    get_channel,

    # Scope
    get_data,
    lpf_on,
    lpf_off,
    get_lpf_state,
    set_impedance_1Mohm,
    set_impedance_50ohm,
    get_impedance,
    get_coupling,
    get_function,
    set_function,
    get_frequency,
    set_frequency,
    get_amplitude,
    set_amplitude,
    get_voltage_offset,
    set_voltage_offset,
    get_burst_mode,
    get_mode,
    set_mode_burst,
    set_mode_cw,
    set_burst_mode_gated,
    set_burst_mode_triggered,


    # Prologix
    set_prologix_chan,
    get_prologix_chan,
    scan_prologix,


    # DMM
    get_tc_temperature,
    set_tc_type,
    get_current,
    get_resistance,
    set_temp_unit_celsius,
    set_temp_unit_farenheit,
    set_temp_unit_kelvin,
    get_temp_unit,

    # Devices
    ## Impedance Analyzer
    Agilent4294A,
    Agilent4395A,
    ## Multimeter
    KeysightDMM34465A,
    ## Scope
    AgilentDSOX4024A,
    AgilentDSOX4034A,
    ## Power Supply
    AgilentE36312A,
    VersatilePower,
    SRSPS310,
    ## Waveform Generator
    Keysight33612A,

    scan_network,

    instrument_reset,
    instrument_clear,
    instrument_get_id,
    instrument_beep_on,
    instrument_beep_off,
    instrument_set_hilevel


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

function __init__()
    @info "init"
    load_config()
end

end #endmodule

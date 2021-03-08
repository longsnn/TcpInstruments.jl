```@meta
CurrentModule = TcpInstruments
```

# General Usage

To connect to an instrument you must know its model and
IP address:

```julia
using TcpInstruments
instrument_handle = initialize(AgilentDSOX4034A, "10.1.30.32")
info(instrument_handle)
data = get_data(instrument_handle)
save(data)
```
When you are done you can close your connection:
```julia
terminate(instrument_handle)
```

If you do not know the ip address of any devices on your network:
```julia
scan_network()
```

By default `scan_network` will check the addresses between
10.1.30.1 to 10.1.30.255 but you may need to scan a different range,
say: 10.1.150.1-255
```julia
scan_network(; ip_network="10.1.150.")
```

## General functions
```@docs
initialize
terminate
info
scan_network
save
load
```

## Power Supply
### AgilentE36312A
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) !== DataType
Pages = ["src/power_supply/AgilentE36312A.jl"]
```
### SRSPS310
This device needs a gpib adapter

As of right now the prologix adapter interface is the only
supported adapter.

Connect your power supply to a prologix adapter then
initialize using the `GPIB_ID` keyword argument.

If you do not know the GPIB Channel ID you can initialize
your device without that flag. Then run `scan_prologix` on
your device. This will tell you what channel is connected
then manually you can use the `set_prologix` function to
set the channel.
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) !== DataType
Pages = ["src/power_supply/SRSPS310.jl"]
```
### VersatilePower
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) !== DataType
Pages = ["src/power_supply/VersatilePower.jl"]
```

## Signal Generator
### Keysight33612A
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) !== DataType
Pages = ["src/signal_generator/Keysight33612A.jl"]
```

## Impedance Analyzer
### Agilent4294A
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) !== DataType
Pages = ["src/impedance_analyzer/Agilent4294A.jl"]
```

### Agilent4395A
#### WIP
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) !== DataType
Pages = ["src/impedance_analyzer/Agilent4395A.jl"]
```

## Oscilloscope
### AgilentDSOX4024A
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) !== DataType
Pages = ["src/oscilloscope/AgilentDSOX4024A.jl"]
```
### AgilentDSOX4034A
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) !== DataType
Pages = ["src/oscilloscope/AgilentDSOX4034A.jl"]
```
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) !== DataType
Pages = ["src/oscilloscope/scope_common.jl"]
```

## Multimeter
### KeysightDMM34465A
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) !== DataType
Pages = ["src/multimeter/KeysightDMM34465A.jl"]
```

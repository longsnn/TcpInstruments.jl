```@meta
CurrentModule = TcpInstruments
```

## Impedance Analyzer
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) === DataType && t <: ImpedanceAnalyzer && t != ImpedanceAnalyzer
```


### Agilent Impedance Analyzer
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) !== DataType
Pages = ["src/impedance_analyzer/all.jl"]
```
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) !== DataType
Pages = ["src/impedance_analyzer/Agilent4294A.jl"]
```
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) !== DataType
Pages = ["src/impedance_analyzer/Agilent4395A.jl"]
```


## Multimeter
```@autodocs
Modules = [TcpInstruments]
Pages = ["src/multimeter/all.jl"]
```

### KeysightDMM34465A
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) !== DataType
Pages = ["src/multimeter/KeysightDMM34465A.jl"]
```


## Oscilloscope
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) === DataType && t <: Oscilloscope && t != Oscilloscope
```

### Agilent Oscilloscope
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) !== DataType
Pages = ["src/oscilloscope/scope_common.jl"]
```


## Power Supply
```@autodocs
Modules = [TcpInstruments]
Pages = ["src/power_supply/all.jl"]
```

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


## Waveform Generator
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) === DataType && t <: WaveformGenerator && t != WaveformGenerator
```

### Keysight Waveform Generator
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) !== DataType
Pages = ["src/waveform_generator/keysight_common.jl"]
```

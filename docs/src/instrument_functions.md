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
Pages = ["src/impedance_analyzer/agilent_common.jl"]
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
Filter = t -> typeof(t) === DataType && t <: MultiMeter && t != MultiMeter
```

### Keysight Multimeter
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) !== DataType
Pages = ["src/multimeter/keysight_common.jl"]
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
Pages = ["src/oscilloscope/agilent_common.jl"]
```


## Power Supply
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) === DataType && t <: PowerSupply && t != PowerSupply
```

### Agilent Power Supply
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) !== DataType
Pages = ["src/power_supply/agilent_common.jl"]
```

### SRS Power Supply
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
Pages = ["src/power_supply/srs_common.jl"]
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

```@meta
CurrentModule = TcpInstruments
```

# Supported Instruments

A list of all currently supported instruments:
```@docs
ImpedanceAnalyzer
MultiMeter
Oscilloscope
PowerSupply
WaveformGenerator
```

## ImpedanceAnalyzer

## Oscilloscope
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) === DataType && t <: Oscilloscope && t != Oscilloscope
```

## MultiMeter
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) === DataType && t <: MultiMeter && t != MultiMeter
```

## PowerSupply
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) === DataType && t <: PowerSupply && t != PowerSupply
```

## WaveformGenerator

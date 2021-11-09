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
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) === DataType && t <: ImpedanceAnalyzer && t != ImpedanceAnalyzer
```

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
```@autodocs
Modules = [TcpInstruments]
Filter = t -> typeof(t) === DataType && t <: WaveformGenerator && t != WaveformGenerator
```

# TcpInstruments

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Build Status](https://travis-ci.com/Orchard-Ultrasound-Innovation/TcpInstruments.jl.svg?branch=master)](https://travis-ci.com/github/Orchard-Ultrasound-Innovation/TcpInstruments.jl)
[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](LICENSE)
[![Coverage Status](https://coveralls.io/repos/github/Orchard-Ultrasound-Innovation/TcpInstruments.jl/badge.svg?branch=master)](https://coveralls.io/github/Orchard-Ultrasound-Innovation/TcpInstruments.jl?branch=master)

Control common lab equipment via SCPI over Ethernet and specifically not be dependent on the NIVISA library that other similar packages often have depended on.

This package is based on code from [GenericInstruments.jl](https://ci.appveyor.com/project/iuliancioarca/GenericInstruments-jl)
which was again based on [Instruments.jl](https://github.com/BBN-Q/Instruments.jl). 

SCPI is supported on almost all modern pieces of lab equipment but this code has been tested on the following devices:
- [X] Oscilloscope Keysight DSOX4034A
- [ ] Oscilloscope Keysight DSOX4024A
- [ ] Multimeter Keysight DMM34465A
- [X] Signal generator Keysight 33612A
- [X] Power supply Agilent E36312A
- [ ] Power supply Keysight 36312A
- [ ] HV power supply SRS PS310 via Prologix GPIB to Ethernet adaptor
- [X] Power supply Versatile Power 100-10 XR
- [ ] Impedance analyser Agilent 4395A (with 43961A imp. probe)


This package is under active development so expect breaking changes. 

For more information on every type of instrument as well as
their available functions and how they work:

```
julia --project=.
julia>using TcpInstruments
julia>?
help>Instrument
```

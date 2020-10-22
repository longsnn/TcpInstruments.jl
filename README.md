# TcpInstruments

[![Build Status](https://travis-ci.com/github/Orchard-Ultrasound-Innovation/TcpInstruments.jl.svg?branch=master)](https://travis-ci.com/github/Orchard-Ultrasound-Innovation/TcpInstruments.jl)


Control common lab equipment via SCPI over Ethernet and specifically not be dependent on the NIVISA library that other similar packages often have depend on.

This package is based on the code from: https://ci.appveyor.com/project/iuliancioarca/GenericInstruments-jl
which again is based on https://github.com/BBN-Q/Instruments.jl. 

SCPI is supported on almost all modern pieces of lab equipment but this code has been tested on the following devices:
- [ ] Oscilloscope Keysight DSOX4034A
- [ ] Multimeter Keysight DMM34465A
- [ ] Signal generator Keysight 33612A
- [ ] Power supply Agilent E3631A
- [ ] Power supply Keysight 36312A
- [ ] HV power supply SRS PS310 via Prologix GPIB to Ethernet adaptor
- [ ] Power supply Versatile Power 100-10 XR
- [ ] Impedance analyser Agilent 4395A (with 43961A imp. probe)


This package is under active development so expect breaking changes. 
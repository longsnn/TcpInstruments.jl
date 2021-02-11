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
- [X] HV power supply SRS PS310 via Prologix GPIB to Ethernet adaptor
- [X] Power supply Versatile Power 100-10 XR
- [ ] Impedance analyser Agilent 4395A (with 43961A imp. probe)


This package is under active development so expect breaking changes. 

For more information on every type of instrument as well as
their available functions and how they work:

Get our latest lab config:
```
wget https://raw.githubusercontent.com/Orchard-Ultrasound-Innovation/TcpInstruments.jl/master/.tcp.yml
```
Now install the package
```
julia 
julia>] add https://github.com/Orchard-Ultrasound-Innovation/TcpInstruments.jl
julia>using TcpInstruments
julia>?
help>Instrument
```

Get the newest version:
```
julia>] up
```

# Using this library
To use any device you must first initialize it.

handler = initialize({name-of-device}, "{ip-address}")

The ip address can also have a port. If no port is specified, 
5025 is used by default.

Thus `"10.1.30.36"` defaults to `"10.1.30.36:5025"`

To see the list of commands for this device, look up this device
in the documentation or in the repl: `help>{name-of-device}`

# Examples
## Waveform Generator
###  Creating a Sin Wave Example:
```
wave = initialize(Keysight33612A, "10.1.30.36")
set_mode_cw(wave) # Set to continuous waveform mode
set_function(wave, "SIN")
set_frequency(wave, 1000)
set_amplitude(wave, 0.1)
set_voltage_offset(wave, 0)
enable_output(wave) # Starts wave

```
## GPIB Power Supply (SRSPS310) used with Prologix Controller
### Initialize Prologix Channel
To a initialize a device that is connected with a prologix
controller you must specify what prologix channel the device
is on.
```
p = initialize(SRSPS310, "10.1.30.37:1234"; prologix_chan=2)
```
If you don't know the channel you can figure it out and configure
it manually:
```
julia>using TcpInstruments
julia>p = initialize(SRSPS310, "10.1.30.37:1234")
julia>scan_prologix(p)
2 => "PS310"
julia>set_prologix(p, 2)
julia>get_prologix(p)
2
```
### Using SRSPS310 Power Supply
```
p = initialize(SRSPS310, "10.1.30.37:1234"; prologix_chan=2)
set_voltage_limit(p, 1250)
set_voltage(p, 1250)
set_current_limit(p, 0.021) # 21mA
enable_output(p)
```

## Autoinitialize
Additionally you can create a `.tcp.yml` file. You 
can save the ip address of all your devices 
in one easy-to-find place so they don't have to be hardcoded in scripts.

Format of .tcp.yml file:
```
{name-of-device}:
    "{ip-address}"

# GPIB Device connected with a prologix controller
{name-of-device}:
    Prologix: {channel-number}
    Address: "{ip-address}"
```

Let's create a new .tcp.yml file or ensure the two previous
devices are found in our .tcp.yml file
```
Keysight33612A:
    "10.1.30.36"
SRSPS310:
    Prologix: 2
    Address: "10.1.30.37:1234"
```

Recompile new config
```
julia --project=.
julia>using TcpInstruments; TcpInstruments.init_tcp_yaml()
```

The .tcp.yml file must be in the current directory of our project. If you have multiple scripts in different directories you can
can also place the config file in your home directory: `~/.tcp.yml`.

Each project will first look for a config in the current directory and if none is found it will look in the home directory.

The two devices from above can now be initialized as follows:
```
wave = initialize(Keysight33612A)
p = initialize(SRSPS310)
```
## Power Supplies
# VersatilePowerBench100_10XR
```
# Initialize automatically puts this power supply in remote mode
pwr = initialize(VersatilePowerBench100_10XR)

set_voltage(pwr, 20)
set_current_limit(pwr, 4)
enable_output(pwr)

# Closes connection as with other devices but also puts this
# device back into local mode
terminate(pwr)


```
# AgilentE36312A
```
pwr = initialize(AgilentE36312A)

set_channel(pwr, 1)
set_current_limit(pwr, 1)
set_voltage(pwr, 2)
enable_output(pwr) # Enables output on channel 1

set_channel(pwr, 2)
set_voltage(pwr, "10")
enable_output(pwr) # Enables output on channel 2

set_channel(pwr, 3)
set_voltage(pwr, "MAX")

set_voltage(pwr, "MIN"; chan=1) # Changes voltage of channel 1

get_voltage(pwr) # Get voltage channel 3
get_voltage(pwr; chan=2)
get_voltage(pwr; chan=1)

enable_output(pwr) # Enables output on channel 3
```

## Scope
### AgilentDSOX4034A
```
scope = initialize(AgilentDSOX4034A)

# Turn on Low Pass Filter 25MHz
lpf_on(scope)

# See that low pass filter is on
get_lpf_state(scope)

# Turn Off Low Pass Filter 25MHz
lpf_off(scope)

# See that low pass filter is off
get_lpf_state(scope)


set_impedance_one(scope)
@info get_impedance(scope)

set_impedance_fifty(scope)
@info get_impedance(scope)

# Get data from channel 1
data = get_data(scope, 1)

# Get data from channel 1, 2, & 4
# Returns 3 element array of data from each channel
multi_data = get_data(scope, [1,2, 4])


using Plots; gr()

plot(data)

# Plots channel 1
plot(multi_data[1])

# Plots channel 2
plot(multi_data[2])

# Plots channel 4
plot(multi_data[3])
```

# Multiple devices
Lets say you want to use a waveform generator, power supply
and oscilloscope all at once.
```
using TcpInstruments
using Plots; gr()

scope = initialize(AgilentDSOX4034A)
pwr = initialize(VersatilePowerBench100_10XR)
wave = initialize(Keysight33612A)

set_mode_cw(wave)
set_function(wave, "SIN")
set_frequency(wave, 1000)
set_amplitudewave, 0.1)
set_voltage_offset(wave, 0)
enable_output(wave)

set_voltage(pwr, 20)
set_current_limit(pwr, 4)
enable_output(pwr)

chan1, chan2 = get_data(scope, [1,2])
plot(chan1)
```

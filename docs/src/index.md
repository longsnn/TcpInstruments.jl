# TcpInstruments.jl

TcpInstruments allows you to control a variety of internet-enabled instruments

## Installation
TcpInstruments can be installed using the Julia package manager. From the Julia REPL, type ] to enter the Pkg REPL mode and run

```
pkg> add TcpInstruments
```

## General Usage

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

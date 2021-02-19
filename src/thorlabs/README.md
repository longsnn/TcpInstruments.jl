# Thorlabs LTS150 XYZ Stage 
We currently use the Kinesis Windows DLL to control the XYZ Stage.

As such this code will only work on a Windows machine that has
been properly configured.

TODO: Make a remote client mode maybe?

## Setup
This guide explains how to setup a clean Windows 10 install.

### Install choco
Start a new powershell as administrator.

`Set-ExecutionPolicy -Scope CurrentUser`

Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

## Install git
`choco install git`

## Install python
`choco install python --version=3.6.3`

As of this document any version above 3.6.3 will not work

`pip install --upgrade pip`

`pip install wheel`

`pip install pythonnet`

## Install julia
`choco install julia`

## Install kinesis
Download & Install [Kinesis](https://www.thorlabs.com/software_pages/ViewSoftwarePage.cfm?Code=Motion_Control&viewtab=0)

## Install TcpInstruments
```
pkg> add https://github.com/Orchard-Ultrasound-Innovation/TcpInstruments.jl
```

Add python: "python" to .tcp.yml:
```
edit_config
```

Load python
```
load_python()
```


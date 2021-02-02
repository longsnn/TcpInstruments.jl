struct BenchXR <: PowerSupply end


"""
    This will enable an output on a device.

    Arguments:
      - obj
        - must be a Power Supply Instrument
    Supported Instruments:
       - Power supply
"""
enable_output!(obj::Instr{BenchXR}) = write(obj, "OUTPut ON")

"""
    This will disable an output on a device.

    Arguments:
      - obj
        - must be a Power Supply Instrument
    Supported Instruments:
       - Power supply
"""
disable_output!(obj::Instr{BenchXR}) = write(obj, "OUTPut OFF")


"""
    This will return the state of an output on a device.

    Arguments:
      - obj
        - must be a Power Supply Instrument
    Supported Instruments:
       - Power supply

    Returns:
      String: {"OFF"|"ON"}
"""
get_output(obj::Instr{BenchXR}) = query(obj, "OUTPut?")

"""
    This will change the voltage output of a device.


    Supported Instruments:
       - Power supply

    Returns:
      Nothing
"""
set_voltage!(obj::Instr{BenchXR}, num) = write(obj, "VOLTage $num")

"""
    This will return the voltage of a device

    Supported Instruments:
       - Power supply

    Returns:
      Voltage
"""
get_voltage(obj::Instr{BenchXR}) = query(obj, "VOLTage?")

"""
    This will change the current limit of a device 

    Supported Instruments:
       - Power supply

    Returns:
      Nothing
"""
set_current_limit!(obj::Instr{BenchXR}, num) = write(obj, "CURRent $num")

"""
    This will return the current limit of a device.


    Supported Instruments:
       - Power supply

    Returns:
      Current Limit
"""
get_current_limit(obj::Instr{BenchXR}) = query(obj, "CURRent?")


lock!(obj::Instr{BenchXR}) = write(obj, "SYSTem:MODe RWLock")

unlock!(obj::Instr{BenchXR}) =   write(obj, "SYSTem:MODe LOCal")

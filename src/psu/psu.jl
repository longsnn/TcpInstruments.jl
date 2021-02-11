include("./AgilentE36312A.jl")
include("./BenchXR.jl")
include("./SRSPS310.jl")

"""
    This will set the global channel on a device.

    Any commands like set_voltage! that affect the
    device with respect to a specific channel will be impacted
    by this command.

    By setting the channel on a device, all subsequent commands
    will operate on that channel unless they allow for an optional channel argument.

    Parameters:
      - obj
        - must be a Power Supply Instrument
      - chan
        - This can be a string or int: 1, 2, 3 .. to n
        where n is the total number of channels

    Supported Instruments:
       - Power supply

    Returns:
      Nothing
"""
set_channel!(obj::Instrument; v=false) = udef(@codeLocation)

"""
    This will return the global or default channel of a device.

    Allows you to see what the global channel is set to at the
    moment

    Parameters:
      - obj
        - must be a Power Supply Instrument
      - chan
        - This can be a string or int: 1, 2, 3 .. to n
        where n is the total number of channels
      - v
        - optional boolean flag argument that is set to false
        - setting to `true` will print the verbose channel name

    Supported Instruments:
       - Power supply

    Returns:
      String
        - {"1"|"2"|...}
        - when v == true: "P6V", .. etc
"""
get_channel(obj::Instrument; v=false) = udef(@codeLocation)

enable_output!(obj::Instrument; v=false) = udef(@codeLocation)
disable_output!(obj::Instrument; v=false) = udef(@codeLocation)

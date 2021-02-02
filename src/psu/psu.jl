include("./AgilentE36312A.jl")
include("./BenchXR.jl")

macro codeLocation()
           return quote
               st = stacktrace(backtrace())
               myf = ""
               for frm in st
                   funcname = frm.func
                   if frm.func != :backtrace && frm.func!= Symbol("macro expansion")
                       myf = frm.func
                       break
                   end
               end
               println("Running function ", $("$(__module__)"),".$(myf) at ",$("$(__source__.file)"),":",$("$(__source__.line)"))
               
               myf
           end
       end

function psu_chan(obj, num, cmd)
    original_chan = get_channel(obj)
    num != 0 && set_channel!(obj, num)
    ans = ""
    if occursin("?", cmd)
        ans = query(obj, cmd)
    else 
        write(obj, cmd)
    end
    num != 0 && set_channel!(obj, original_chan)
    ans
end

"""
    This will enable an output on a device.

    If the device has multiple channels it will enable the
    device for the currently selected channel. To see the
    channel that will effected use the `get_channel` function.

    If you want to enable a different channel, first use
    `set_channel!` to choose the channel. Running this function
    subsequently will enable that channel

    Arguments:
      - obj
        - must be a Power Supply Instrument
    Supported Instruments:
       - Power supply
"""
enable_output!(obj) = write(obj, ":OUTPUT:STATe ON")

"""
    This will disable an output on a device.

    If the device has multiple channels it will disable the
    device for the currently selected channel. To see the
    channel that will effected use the `get_channel` function.

    If you want to disable a different channel, first use
    `set_channel!` to choose the channel. Running this function
    subsequently will disable that channel

    Arguments:
      - obj
        - must be a Power Supply Instrument
    Supported Instruments:
       - Power supply
"""
disable_output!(obj) = write(obj, ":OUTPUT:STATe OFF")


"""
    This will return the state of an output on a device.

    If the device has multiple channels is will display the
    state of the currently selected channel. To see the
    channel that will read use the `get_channel` function.

    If you want to see the state of a different channel, first use
    `set_channel!` to choose the channel. Running this function
    subsequently will disable that channel

    Arguments:
      - obj
        - must be a Power Supply Instrument
    Supported Instruments:
       - Power supply

    Returns:
      String: {"0"|"1"}
"""
get_output(obj) = query(obj, ":OUTPUT:STATE?")

"""
    This will change the voltage output voltage of a device.



    Parameters:
      - obj
        - must be a Power Supply Instrument
      - num
        - integer or decimal of the desired voltage
      - chan
        - This is an optional parameter
        - If not provided it will use the default channel (see `set_channel!`)
        - Otherwise this can be a string or int: 1, 2, 3 .. to n
        where n is the total number of channels

    Supported Instruments:
       - Power supply

    Returns:
      Nothing
"""
set_voltage!(obj, num; chan=0) = psu_chan(obj, chan, "SOURce:VOLTage $num")

"""
    This will return the voltage of a device's channel.


    Parameters:
      - obj
        - must be a Power Supply Instrument
      - chan
        - This is an optional parameter
        - If not provided it will use the default channel (see `set_channel!`)
        - Otherwise this can be a string or int: 1, 2, 3 .. to n
        where n is the total number of channels

    Supported Instruments:
       - Power supply

    Returns:
      Voltage
"""
get_voltage(obj; chan=0) = psu_chan(obj, chan, "SOURce:VOLTage?")

"""
    This will change the current limit of a device on a given 
    channel


    Parameters:
      - obj
        - must be a Power Supply Instrument
      - num
        - integer or decimal of the desired current limit
      - chan
        - This is an optional parameter
        - If not provided it will use the default channel (see `set_channel!`)
        - Otherwise this can be a string or int: 1, 2, 3 .. to n
        where n is the total number of channels

    Supported Instruments:
       - Power supply

    Returns:
      Nothing
"""
set_current_limit!(obj, num; chan=0) = psu_chan(obj, chan, "SOURce:CURRent $num")

"""
    This will return the current limit of a device.


    Parameters:
      - obj
        - must be a Power Supply Instrument
      - chan
        - This is an optional parameter
        - If not provided it will use the default channel (see `set_channel!`)
        - Otherwise this can be a string or int: 1, 2, 3 .. to n
        where n is the total number of channels

    Supported Instruments:
       - Power supply

    Returns:
      Current Limit
"""
get_current_limit(obj; chan=0) = psu_chan(obj, chan, "SOURce:CURRent?")

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
set_channel!(obj::Instrument; v=false) = error("$(@codeLocation) not implemented")

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
get_channel(obj::Instrument; v=false) = error("$(@codeLocation) not implemented")

lock!(obj) =  error("$(@codeLocation) not implemented")

unlock!(onj) =  error("$(@codeLocation) not implemented")




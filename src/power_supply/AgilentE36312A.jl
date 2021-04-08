"""

# Available functions
- `enable_output()`
- `disable_output()`
- `set_voltage(voltage)`
- `get_voltage()`
- `set_current_limit(current)`
- `get_current_limit()`
- `set_channel(channel)`
- `get_channel()`
"""
struct AgilentE36312A <: PowerSupply end

"""
    set_channel(obj::Instr{AgilentE36312A}, chan) 

This will set the global channel on a device.

Any commands like set_voltage that affect the
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
set_channel(obj::Instr{AgilentE36312A}, chan) = write(obj, "INST:NSEL $chan")

"""
    get_channel(obj::Instr{AgilentE36312A}; v=false) 

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
get_channel(obj::Instr{AgilentE36312A}; v=false) = v ? query(obj, "INST:SEL?") : strip(query(obj, "INST:NSEL?"), '+')


function psu_chan(obj, num, cmd; float=false)
    original_chan = get_channel(obj)
    num != 0 && set_channel(obj, num)
    ans = ""
    if occursin("?", cmd)
        if float
            ans = f_query(obj, cmd)
        else
            ans = query(obj, cmd)
        end
    else
        write(obj, cmd)
    end
    num != 0 && set_channel(obj, original_chan)
    ans
end

"""
    enable_output(obj::Instr{AgilentE36312A})

This will enable an output on a device.

If the device has multiple channels it will enable the
device for the currently selected channel. To see the
channel that will effected use the `get_channel` function.

If you want to enable a different channel, first use
`set_channel` to choose the channel. Running this function
subsequently will enable that channel

Arguments:
  - obj
    - must be a Power Supply Instrument
Supported Instruments:
   - Power supply
"""
enable_output(obj::Instr{AgilentE36312A}) = write(obj, ":OUTPUT:STATe ON")

"""
    disable_output(obj::Instr{AgilentE36312A})

This will disable an output on a device.

If the device has multiple channels it will disable the
device for the currently selected channel. To see the
channel that will effected use the `get_channel` function.

If you want to disable a different channel, first use
`set_channel` to choose the channel. Running this function
subsequently will disable that channel

Arguments:
  - obj
    - must be a Power Supply Instrument
Supported Instruments:
   - Power supply
"""
disable_output(obj::Instr{AgilentE36312A}) = write(obj, ":OUTPUT:STATE OFF")


"""
    get_output(obj::Instr{AgilentE36312A})

This will return the state of an output on a device.

If the device has multiple channels is will display the
state of the currently selected channel. To see the
channel that will read use the `get_channel` function.

If you want to see the state of a different channel, first use
`set_channel` to choose the channel. Running this function
subsequently will disable that channel

Arguments:
  - obj
    - must be a Power Supply Instrument
Supported Instruments:
   - Power supply

Returns:
  String: {"0"|"1"}
"""
function get_output(obj::Instr{AgilentE36312A})
    output = query(obj, ":OUTPUT:STATE?")
    if output == "0"
        return false
    elseif output == "1"
        return true
    else
        error("Undefined output: $output")
    end
end

"""
    set_voltage(obj::Instr{AgilentE36312A}, num::Voltage; chan=0) 

This will change the voltage output voltage of a device.



Parameters:
  - obj
    - must be a Power Supply Instrument
  - num
    - integer or decimal of the desired voltage
  - chan
    - This is an optional parameter
    - If not provided it will use the default channel (see `set_channel`)
    - Otherwise this can be a string or int: 1, 2, 3 .. to n
    where n is the total number of channels

Supported Instruments:
   - Power supply

Returns:
  Nothing
"""
set_voltage(obj::Instr{AgilentE36312A}, num::Voltage; chan=0) = psu_chan(obj, chan, "SOURCE:VOLTAGE $(raw(num))")

"""
    get_voltage(obj::Instr{AgilentE36312A}; chan=0)

This will return the voltage of a device's channel.


Parameters:
  - obj
    - must be a Power Supply Instrument
  - chan
    - This is an optional parameter
    - If not provided it will use the default channel (see `set_channel`)
    - Otherwise this can be a string or int: 1, 2, 3 .. to n
    where n is the total number of channels

Supported Instruments:
   - Power supply

Returns:
  Voltage
"""
get_voltage(obj::Instr{AgilentE36312A}; chan=0) = psu_chan(obj, chan, "SOURCE:VOLTAGE?"; float=true) * V

"""
    set_current_limit(obj::Instr{AgilentE36312A}, num::Current; chan=0) 

This will change the current limit of a device on a given
channel


Parameters:
  - obj
    - must be a Power Supply Instrument
  - num
    - Desired current limit of type Unitful Amps: 1.0u"A"
  - chan
    - This is an optional parameter
    - If not provided it will use the default channel (see `set_channel`)
    - Otherwise this can be a string or int: 1, 2, 3 .. to n
    where n is the total number of channels

Supported Instruments:
   - Power supply

Returns:
  Nothing
"""
set_current_limit(obj::Instr{AgilentE36312A}, num::Current; chan=0) = psu_chan(obj, chan, "SOURCE:CURRENT $(raw(num))")

"""
    get_current_limit(obj::Instr{AgilentE36312A}; chan=0)

This will return the current limit of a device.


Parameters:
  - obj
    - must be a Power Supply Instrument
  - chan
    - This is an optional parameter
    - If not provided it will use the default channel (see `set_channel`)
    - Otherwise this can be a string or int: 1, 2, 3 .. to n
    where n is the total number of channels

Supported Instruments:
   - Power supply

Returns:
  Current Limit
"""
get_current_limit(obj::Instr{AgilentE36312A}; chan=0) = psu_chan(obj, chan, "SOURCE:CURRENT?"; float=false) * A

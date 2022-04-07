"""
    enable_output(obj::Instr{<:SRSPowerSupply})

This will enable an output on a device.

Arguments:
  - obj
    - must be a Power Supply Instrument
Supported Instruments:
   - Power supply
"""
enable_output(obj::Instr{<:SRSPowerSupply}) = write(obj, "HVON")

"""
    disable_output(obj::Instr{<:SRSPowerSupply})

This will disable an output on a device.

Arguments:
  - obj
    - must be a Power Supply Instrument
Supported Instruments:
   - Power supply
"""
disable_output(obj::Instr{<:SRSPowerSupply}) = write(obj, "HVOF")

"""
    get_output_status(obj::Instr{<:SRSPowerSupply})
This will get and return whether the output from SRSPS310 is enabled.

Arguments:
    - obj
    - must be a Power Supply Instrument
Supported Instruments:
    - Power supply

# Returns
- true if High Voltage Output is On
- false if High Voltage Output is Off
"""
get_output_status(obj::Instr{<:SRSPowerSupply}) = query(obj, "*STB? 7") == "1" ? true : false


"""
    set_voltage(obj::Instr{<:SRSPowerSupply}, volt::Voltage; [delta_volt::Voltage, delta_time::Time, verbose::Bool])

Sets the output voltage output of a SRSPS310 power supply.
optional parameters:
delta_volt and delta_time can be used to set the ramping speed when setting a new voltage.
- delta_volt sets the maximum of each voltage step.  (std value: `Inf *u"V"`)
- delta_time sets the minimum time between each voltage update. (std value: `100u"ms"`)
- verbose when true prints info on ramping speed and steps (std value: `false`)

Units are handled by the package `Unitful`.

Currently set voltage limits can read using `get_voltage_limit()`.

Examples:
```
julia> psu_h = initialize(SRSPS310)
julia> set_voltage(psu_h, 11.1u"V")
julia> set_voltage(psu_h, 1100"mV")
julia> set_voltage(psu_h, 100"V", delta_volt = 2u"V", delta_time=100u"ms", verbose=true)
```

Returns: `Nothing`
"""
function set_voltage(obj::Instr{<:SRSPowerSupply}, v_end::Voltage; delta_volt::Voltage=Inf*u"V", delta_time::Time=100u"ms", verbose::Bool=false)
    if delta_volt == Inf*u"V"
        _set_voltage(obj, v_end)
    else # TODO: Fix for negative ramps
        v_start = get_voltage(obj)
        v_diff = v_end - v_start
        nsteps = ceil(v_diff/delta_volt)
        v_step = v_diff / nsteps
        v_arr  = v_start+v_step:v_step:v_end
        ramp_time = (length(v_arr)-1)*delta_time
        dv_dt = uconvert(V/s, v_diff/ramp_time)

        if verbose
            println("dV/dt: $(dv_dt), Ramping time: $(ramp_time), Voltage steps: $(length(v_arr)).")
        end

        for (idx, v) in enumerate(v_arr)
            _set_voltage(obj, v)
            if idx != length(v_arr)
                sleep(raw(delta_time))
            end
        end
    end
    return nothing
end

_set_voltage(obj::Instr{<:SRSPowerSupply}, v::Voltage) = write(obj, "VSET$(raw(v))")

"""
    get_voltage(obj::Instr{<:SRSPowerSupply})

This will return the voltage of a device

Voltage Limit: 1250V

Supported Instruments:
   - Power supply

Returns:
  Voltage
"""
get_voltage(obj::Instr{<:SRSPowerSupply}) = f_query(obj, "VSET?") * V

"""
    set_voltage_limit(::SRSPS310, voltage_limit)

This will change the voltage limit of a device.

Max Voltage Limit: 1250V

Supported Instruments:
   - Power supply

Returns:
  Nothing
"""
set_voltage_limit(obj::Instr{<:SRSPowerSupply}, num::Voltage) = write(obj, "VLIM$(raw(num))")

"""
    get_voltage_limit(obj::Instr{<:SRSPowerSupply})

This will return the voltage limit of a device

Voltage Limit: 1250V

Supported Instruments:
   - Power supply

Returns:
  Voltage
"""
get_voltage_limit(obj::Instr{<:SRSPowerSupply}) = f_query(obj, "VLIM?") * V

"""
    set_current_limit(obj::Instr{<:SRSPowerSupply}, num::Current)

This will change the current limit of a device

MIN Value: 0
Max Value: { 2.1e-3 | 0.021 } (21mA)

Supported Instruments:
   - Power supply

Returns:
  Nothing
"""
function set_current_limit(obj::Instr{<:SRSPowerSupply}, num::Current)
    write(obj, "ILIM$(raw(num))")
end

"""
    get_current_limit(obj::Instr{<:SRSPowerSupply})

This will return the current limit of a device.


Supported Instruments:
   - Power supply

Returns:
  Current Limit
"""
get_current_limit(obj::Instr{<:SRSPowerSupply}) = f_query(obj, "ILIM?") * A

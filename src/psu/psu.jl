struct AgilentE36312A <: PowerSupply end
include("./AgilentE36312A.jl")

function psu_chan(obj, num, cmd)
    original_chan = strip(get_channel(obj), '+')
    original_chan = num == 0 ? "" : "INST:NSEL $original_chan"
    temp_chan = num == 0 ? "" : "INST:NSEL $num"
    write(obj, temp_chan)
    ans = ""
    if occursin("?", cmd)
        ans = query(obj, cmd)
    else 
        write(obj, cmd)
    end
    write(obj, original_chan)
    ans
end

enable_output!(obj) = write(obj, ":OUTPUT:STATe ON")
disable_output!(obj) = write(obj, ":OUTPUT:STATe OFF")
get_output(obj) = query(obj, ":OUTPUT:STATE?")

set_voltage!(obj, num; chan=0) = psu_chan(obj, chan, "SOURce:VOLTage $num")
get_voltage(obj; chan=0) = psu_chan(obj, chan, "SOURce:VOLTage?")

set_current_limit!(obj, num; chan=0) = psu_chan(obj, chan, "SOURce:CURRent $num")
get_current_limit(obj; chan=0) = psu_chan(obj, chan, "SOURce:CURRent?")

set_channel!(obj, chan) = write(obj, "INST:NSEL $chan")
get_channel(obj; v=false) = v ? query(obj, "INST:SEL?") : query(obj, "INST:NSEL?")




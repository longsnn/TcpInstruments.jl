struct AgilentE36312A <: PowerSupply end
include("./AgilentE36312A.jl")

enable_output!(obj) = write(obj, ":OUTPUT:STATe ON")
disable_output!(obj) = write(obj, ":OUTPUT:STATe OFF")
get_output(obj) = query(obj, ":OUTPUT:STATE?")

set_voltage!(obj, num; chan=1) = write(obj, "INST:NSEL $chan\n; SOURce:VOLTage $num")
get_voltage(obj; chan=1) = query(obj, "INST:NSEL $chan\n; SOURce:VOLTage?"), "volts?"

set_current_limit!(obj, num; chan=1) = write(obj, "INST:NSEL $chan\n; SOURce:CURRent $num")
get_current_limit(obj; chan=1) = query(obj, "INST:NSEL $chan\n; SOURce:CURRent?")

set_channel!(obj, chan) = write(pwr, "INST:NSEL $chan")
get_channel(obj, chan; v=false) = v ? query(pwr, "INST:SEL?") : query(pwr, "INST:NSEL?")




using TcpInstruments
using Test

@info "Creating AgilentE36312A at 10.1.30.34"
@info "Connecting..."
pwr = initialize(AgilentE36312A, "10.1.30.34")
#pwr = TcpInstruments.GenericInstrument(:dummy, "10.1.30.34")
@info pwr

# pwr |> TcpInstruments.instrument_reset
#
@info query(pwr, "*IDN?")
@info query(pwr, "*PSC?")
@info query(pwr, "*TST?"), "TST?"

"""
Spec:
enable_output()
disable_output()
set_voltage(x)
get_voltage()
set_current_limit(x)
get_current_limit()
"""

"""
@info query(pwr, ":OUTPUT:STATE?"), "STATE"
write(pwr, ":OUTPUT:STATe ON")
@info query(pwr, ":OUTPUT:STATE?"), "STATE"
write(pwr, ":OUTPUT:STATe OFF")
@info query(pwr, ":OUTPUT:STATE?"), "STATE"
"""

"""
@info query(pwr, "SOURce:CURRent?"), "current?"
@info query(pwr, "SOURce:VOLTage?"), "volts?"
@info write(pwr, "SOURce:VOLTage 5"), "volts"
@info query(pwr, "SOURce:CURRent?"), "current?"
@info query(pwr, "SOURce:VOLTage?"), "volts?"
@info write(pwr, "SOURce:VOLTage 0"), "volts"
@info query(pwr, "SOURce:VOLTage?"), "volts?"
@info write(pwr, "SOURce:CURRent 5"), "current?"
@info query(pwr, "SOURce:CURRent?"), "current?"
"""

@testset "Output" begin
    @info get_output(pwr), "OUTPUT"
    enable_output!(pwr)
    @info get_output(pwr), "OUTPUT"
    disable_output!(pwr)
    @info get_output(pwr), "OUTPUT"
    enable_output!(pwr)
end

@testset "Current" begin
    @info get_current_limit(pwr)
    set_current_limit!(pwr, 1)
    @info get_current_limit(pwr)
    set_current_limit!(pwr, 2)
    @info get_current_limit(pwr)
    set_current_limit!(pwr, 3)
    @info get_current_limit(pwr)
    set_current_limit!(pwr, 4)
    @info get_current_limit(pwr)
    set_current_limit!(pwr, 0)
    @info get_current_limit(pwr)
    set_current_limit!(pwr, "MAX")
    @info get_current_limit(pwr)
    set_current_limit!(pwr, "MIN")
    @info get_current_limit(pwr)
    set_current_limit!(pwr, 5)
    @info get_current_limit(pwr)
end

@testset "Voltage" begin
    for i in 1:3
        @info "CHANNEL: $i"
        @info get_voltage(pwr; chan=i)
        set_voltage!(pwr, 2; chan=i)
        @info get_voltage(pwr; chan=i)
        set_voltage!(pwr, 4; chan=i)
        @info get_voltage(pwr; chan=i)
        set_voltage!(pwr, 6; chan=i)
        @info get_voltage(pwr; chan=i)
        set_voltage!(pwr, 8; chan=i)
        @info get_voltage(pwr; chan=i)
        set_voltage!(pwr, 20; chan=i)
        @info get_voltage(pwr; chan=i)
        set_voltage!(pwr, 25; chan=i)
        @info get_voltage(pwr; chan=i)
        set_voltage!(pwr, 0; chan=i)
        @info get_voltage(pwr; chan=i)
        set_voltage!(pwr, "MAX"; chan=i)
        @info get_voltage(pwr; chan=i)
        set_voltage!(pwr, "MIN"; chan=i)
        @info get_voltage(pwr; chan=i)
    end
end

@info query(pwr, "INST:NSEL?")
@info query(pwr, "APPLy? CH1"), 1
@info query(pwr, "APPLy? CH2"), 2
@info query(pwr, "APPLy? CH3"), 3

terminate(pwr)

@info "Successfully disconnected"
@info "Goodbye"

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

@testset "Output" begin
    @info get_output(pwr), "OUTPUT"
    enable_output!(pwr)

    @info get_output(pwr), "OUTPUT"
    disable_output!(pwr)
    set_channel!(pwr, 3)
    @test get_output(pwr) == "0"
    set_channel!(pwr, 2)
    disable_output!(pwr)
    @test get_output(pwr) == "0"
    set_channel!(pwr, 1)
    disable_output!(pwr)
    @test get_output(pwr) == "0"

    enable_output!(pwr)

    @test get_output(pwr) == "1"
    set_channel!(pwr, 2)
    @test get_output(pwr) == "0"
    set_channel!(pwr, 3)
    @test get_output(pwr) == "0"

    set_channel!(pwr, 2)
    enable_output!(pwr)
    @test get_output(pwr) == "1"
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

set_channel!(pwr, 3)
set_voltage!(pwr, 7.7; chan=2)
@test get_channel(pwr) == "+3"
set_voltage!(pwr, 7.7)
@info get_voltage(pwr)
@info get_channel(pwr)

terminate(pwr)

@info "Successfully disconnected"
@info "Goodbye"

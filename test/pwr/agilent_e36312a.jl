using TcpInstruments
using Test

pwr = initialize(AgilentE36312A)
@info "Successfully connected $(pwr.model) at $(pwr.address)" 


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
    @info get_output(pwr)
    enable_output!(pwr)

    @info get_output(pwr), "OUTPUT"
    disable_output!(pwr)
    set_channel!(pwr, 3)
    @test get_output(pwr) == false
    set_channel!(pwr, 2)
    disable_output!(pwr)
    @test get_output(pwr) == false
    set_channel!(pwr, 1)
    disable_output!(pwr)
    @test get_output(pwr) == false

    enable_output!(pwr)

    @test get_output(pwr) == true
    set_channel!(pwr, 2)
    @test get_output(pwr) == false
    set_channel!(pwr, 3)
    @test get_output(pwr) == false

    set_channel!(pwr, 2)
    enable_output!(pwr)
    @test get_output(pwr) == true
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
    function test_volt(v, i)
        set_voltage!(pwr, v; chan=i)
        ans = get_voltage(pwr; chan=i)
        @info ans
        if ans == 6 && v != 6
            @info "This channel correctly limits to 6V"
        else
            @test ans == v
        end
    end
    for i in 1:3
        @info "CHANNEL: $i"
        test_volt(2, i)
        test_volt(4, i)
        test_volt(6, i)

        test_volt(8, i)
        test_volt(20, i)
        test_volt(25, i)
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
@test get_channel(pwr) == "3"
set_voltage!(pwr, 7.7)
@info get_voltage(pwr)
@info get_channel(pwr)

terminate(pwr)

@info "Successfully disconnected"
@info "Goodbye"

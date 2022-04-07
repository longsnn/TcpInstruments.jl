using TcpInstruments
using Test

pwr = initialize(VersatilePower)
@info "Successfully connected $(pwr.model) at $(pwr.address)" 

"""
Spec:
enable_output()
disable_output()
set_voltage(x)
get_voltage()
set_current_limit(x)
get_current_limit()
remote_mode()
local_mode()
"""

remote_mode(pwr)
@testset "Output" begin
    @info get_output_status(pwr)

    enable_output(pwr)
    @test get_output_status(pwr) == true

    disable_output(pwr)
    @test get_output_status(pwr) == false
end

@testset "Current" begin
    function test_current(cur)
        set_current_limit(pwr, cur)
        @info get_current_limit(pwr)
        @test get_current_limit(pwr) == cur
    end

    test_current(0)
    test_current(1)
    test_current(1.5)
    test_current("1.6")
    test_current(1.72e0)
    test_current(2)
    test_current(3)
    test_current(4)

    set_current_limit(pwr, "MAX")
    @info get_current_limit(pwr)

    set_current_limit(pwr, "MIN")
    @info get_current_limit(pwr)

    test_current(5)
    test_current(0)
end

@testset "Voltage" begin
    @info get_voltage(pwr)
    set_voltage(pwr, 2)
    @info get_voltage(pwr)
    set_voltage(pwr, 4)
    @info get_voltage(pwr)
    set_voltage(pwr, 6)
    @info get_voltage(pwr)
    set_voltage(pwr, 8)
    @info get_voltage(pwr)
    set_voltage(pwr, 20)
    @info get_voltage(pwr)
    set_voltage(pwr, 25)
    @info get_voltage(pwr)
    set_voltage(pwr, 0)
    @info get_voltage(pwr)
    set_voltage(pwr, "MAX")
    @info get_voltage(pwr)
    set_voltage(pwr, "MIN")
    @info get_voltage(pwr)
end


local_mode(pwr)
terminate(pwr)

@info "Successfully disconnected"
@info "Goodbye"

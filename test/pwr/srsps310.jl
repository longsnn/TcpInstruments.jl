using TcpInstruments
using Test

p = initialize(SRSPS310)
@info "Successfully connected $(p.model) at $(p.address)"
"""
# Available functions
- enable_output!()
- disable_output!()
- get_output()
- set_voltage!(volts)
- get_voltage()
- set_current_limit!(current)
- get_current_limit()
"""

@testset "Prologix" begin
    @info get_prologix_chan(p)
    set_prologix_chan!(p, 0)
    @test get_prologix_chan(p) == "0"

    set_prologix_chan!(p, 15)
    @test get_prologix_chan(p) == "15"

    set_prologix_chan!(p, 2)
    @test get_prologix_chan(p) == "2"
    @info get_prologix_chan(p)
end

@testset "Output" begin
    @info get_output
    enable_output!(p)
    @test get_output(p) 

    disable_output!(p)
    @test get_output(p) == false

    enable_output!(p)
end

@testset "Voltage" begin
    @info get_voltage(p)
    @info get_voltage_limit(p)
    set_voltage!(p, 40)
    set_voltage_limit!(p, 200)
    @test get_voltage(p) == 40

    set_voltage!(p, 100)
    @info get_voltage(p)
    @test get_voltage(p) == 100

    set_voltage!(p, 200)
    @info get_voltage(p)
    @test get_voltage(p) == 200

    set_voltage!(p, 201)
    @info get_voltage(p)
    @test get_voltage(p) == 200

    """
    High Voltage Tests:

    set_voltage_limit!(p, 1250)

    set_voltage!(p, 500)
    @info get_voltage(p)
    @test get_voltage(p) == 500

    set_voltage!(p, 1000)
    @info get_voltage(p)
    @test get_voltage(p) == 1000

    set_voltage!(p, 1250)
    @info get_voltage(p)
    @test get_voltage(p) == 1250

    """

    set_voltage!(p, 0)
    @test get_voltage(p) == 0
    @info get_voltage(p)

end

@testset "Current" begin
    function test_current(cur)
        set_current_limit!(p, cur)
        @info get_current_limit(p)
        @test get_current_limit(p) == cur
    end

    test_current(0.001)
    test_current(0.002)
    test_current(0.005)
    test_current(0.010)
    test_current(0.020)
    test_current(0.021)

    test_current(0.000)

end

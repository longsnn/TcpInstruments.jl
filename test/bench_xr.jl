using TcpInstruments
using Test

@info "Creating Bench Power at 10.1.30.35"
@info "Connecting..."
pwr = initialize(BenchXR, "10.1.30.35:8003")
@info pwr

# pwr |> TcpInstruments.instrument_reset
#
@info query(pwr, "*IDN?")

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

lock!(pwr)
@testset "Output" begin
    @info get_output(pwr), "OUTPUT"
    enable_output!(pwr)

    @info get_output(pwr), "OUTPUT"
    disable_output!(pwr)
    @test get_output(pwr) == "OFF"

    enable_output!(pwr)
    @test get_output(pwr) == "ON"

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
    @info get_voltage(pwr)
    set_voltage!(pwr, 2)
    @info get_voltage(pwr)
    set_voltage!(pwr, 4)
    @info get_voltage(pwr)
    set_voltage!(pwr, 6)
    @info get_voltage(pwr)
    set_voltage!(pwr, 8)
    @info get_voltage(pwr)
    set_voltage!(pwr, 20)
    @info get_voltage(pwr)
    set_voltage!(pwr, 25)
    @info get_voltage(pwr)
    set_voltage!(pwr, 0)
    @info get_voltage(pwr)
    set_voltage!(pwr, "MAX")
    @info get_voltage(pwr)
    set_voltage!(pwr, "MIN")
    @info get_voltage(pwr)
end


unlock!(pwr)
terminate(pwr)

@info "Successfully disconnected"
@info "Goodbye"

using TcpInstruments
using Test

try
include("./fake_device.jl")
catch 
@info "External emulator found"
end

function test_initialize(type)
    @info "Creating fake $type instrument at localhost:8080"
    handle = initialize(type, "127.0.0.1:8080")
    @info handle
    @test handle.connected
    @info "Successfully connected"
    return handle
end

# Start Tests
@testset "Fake Instruments" begin

@testset "Scope Interface" begin
    handle = test_initialize(AgilentDSOX4034A)

    id = info(handle)
    @test id == "1"

    lpf_on(handle)
    lpf_off(handle)

    set_impedance_1Mohm(handle)
    set_impedance_50ohm(handle)

    terminate(handle)
    @info "Successfully disconnected"
end

@testset "Keysight34465A" begin
    handle = test_initialize(KeysightDMM34465A)

    id = info(handle)
    @test id == "1"

    set_temp_unit_kelvin(handle)
    set_temp_unit_farenheit(handle)
    set_temp_unit_celsius(handle)

    terminate(handle)
    @info "Successfully disconnected"
end

@testset "SRSPS310" begin
    handle = test_initialize(SRSPS310)
    enable_output(handle)
    disable_output(handle)
    set_current_limit(handle, 1)
    set_current_limit(handle, 2)
    set_current_limit(handle, 5)
    terminate(handle)
    @info "Successfully disconnected"
end

end # End Tests

try
close_emulator()
catch
end

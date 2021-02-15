using TcpInstruments
using Test

try
include("./fake_device.jl")
catch 
@info "External emulator found"
end

@testset "Basic Scope" begin
    @info "Creating dummy instrument at localhost:8080"
    scope_h = initialize(KeysightDSOX4024A, "localhost:8080")
    @info scope_h
    @test scope_h.connected
    @info "Successfully connected"

    id = instrument_get_id(scope_h)
    @test id == "1"

    data_struct = get_data(scope_h, 1)

    @test terminate(dummy) == false
    @info "Successfully disconnected"
    @info "Goodbye"
end




try
close_emulator()
catch
end

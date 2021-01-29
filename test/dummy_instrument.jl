using TcpInstruments
using Test

try
include("./fake_scope.jl")
catch 
@info "External emulator found"
end



# GenericInstrument with Symbols-Based Implementation
@testset "Generic Instrument" begin
    @info "Creating dummy instrument at localhost:8080"
    dummy = GenericInstrument(:dummy, "localhost:8080")
    @info dummy
    @info "Connecting..."
    @test connect!(dummy)
    @info "Successfully connected"
    instrument_reset(dummy)
    write(dummy, "hi")
    @info close!(dummy) == false
    @info "Successfully disconnected"
    @info "Goodbye"
end


# Parametric Type-Based Implementation
@testset "Basic Scope" begin
    @info "Creating dummy instrument at localhost:8080"
    scope_h = initialize(KeysightDSOX4024A, "localhost:8080")
    @info scope_h
    @test scope_h.connected
    @info "Successfully connected"

    instrument_clear(scope_h)
    instrument_reset(scope_h)

    id = instrument_get_id(scope_h)
    @test id == "1"

    #TODO: Implement
    data_struct = get_data(scope_h, 1)


    @test terminate(dummy) == false
    @info "Successfully disconnected"
    @info "Goodbye"
end




try
close_emulator()
catch
end

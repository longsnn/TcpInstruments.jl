using TcpInstruments
using Test

try
include("./fake_scope.jl")
catch 
@info "External emulator found"
end

@info "Creating dummy instrument at localhost:8080"
dummy = TcpInstruments.GenericInstrument(:dummy, "localhost:8080")
@info dummy
@info "Connecting..."

try 
    @test connect!(dummy)
    @info "Successfully connected"
catch e
    @info "Please run `make e` in another terminal if you haven't"
    @info e
end
instrument_reset(dummy)
write(dummy, "hi")
@info close!(dummy) == false
@info "Successfully disconnected"
@info "Goodbye"
try
close_emulator()
catch
end

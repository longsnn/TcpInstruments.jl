using TcpInstruments
using Test

@info "Creating dummy instrument at 10.1.30.32"
scope = TcpInstruments.GenericInstrument(:dummy, "10.1.30.32")
@info scope
@info "Connecting..."

try 
    @test connect!(scope)
    @info "Successfully connected"
catch e
    @info "Please run `make e` in another terminal if you haven't"
    @info e
end

# scope |> TcpInstruments.instrument_reset

@info scope |> disconnect! == false
@info "Successfully disconnected"
@info "Goodbye"

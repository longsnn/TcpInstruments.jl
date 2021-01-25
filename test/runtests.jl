using TcpInstruments
using Test


@testset "TcpInstruments.jl" begin
    # Write your own tests here.

end

@testset "split_str_into_host_and_port" begin
    host = "192.168.1.1"
    port = 5055
    host_str = string(host, ":", port)
    host_out, port_out = TcpInstruments.split_str_into_host_and_port(host_str)
    @test host_out == host
    @test port_out == port

    host_out, port_out = split_str_into_host_and_port(host)
    @test host_out == host
    @test port_out == nothing



end

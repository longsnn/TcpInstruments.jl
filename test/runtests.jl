using TcpInstruments
using Test
using TestSetExtensions


@testset "TcpInstruments.jl" begin
    include("./emulate/test_fake_device.jl")
end

@testset "Util Functions" begin
    @testset "split_str_into_host_and_port" begin
        host = "192.168.1.1"
        port = 5055
        host_str = "$host:$port"
        host_out, port_out = TcpInstruments.split_str_into_host_and_port(host_str)
        @test host_out == host
        @test port_out == port

        host_out, port_out = TcpInstruments.split_str_into_host_and_port(host)
        @test host_out == host
        @test port_out == 0
    end
end

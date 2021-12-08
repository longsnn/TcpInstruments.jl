using TcpInstruments
using Test
using TestSetExtensions
using Unitful

#using Aqua
#Aqua.test_all(TcpInstruments)

const A = u"A"

@testset ExtendedTestSet "TcpInstruments" begin
    #=
    @testset "Fake Scope" begin
        f = initialize(TcpInstruments.FakeDSOX4034A)

        data = get_data(f, 1)
        @test data isa TcpInstruments.ScopeData
        @test length(data.time) == length(data.volt)
        @test data.volt[1] isa Unitful.Voltage

        data = get_data(f, [1,2,3,4])
        @test length(data) == 4
    end

    @testset "FakeDevice" begin
        include("./emulate/test_fake_device.jl")
    end
    =#

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

        @testset "Save to Matlab file" begin
            data = randn(100)u"V"
            data_nounit = ustrip(data)
            filename = "./testfile"

            save(data, filename = filename, format = :matlab)
            data_loaded = load(filename*".mat")

            @test data_loaded == data_nounit

            rm(filename*".mat")
        end

    end



function test_number_and_unit(function_name, val, true_val_scaled, true_unit)
    scaled_val, unit = function_name(val)
    @test (scaled_val, unit) == (true_val_scaled, true_unit)
end

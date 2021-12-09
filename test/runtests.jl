using TcpInstruments
using Test
using TestSetExtensions
using Unitful

#using Aqua
#Aqua.test_all(TcpInstruments)

const A = u"A"

@testset ExtendedTestSet "TcpInstruments" begin

    "Helper function: expected_number_and_unit(function_name, val, true_val_scaled, true_unit)"
    function expected_number_and_unit(function_name, val, true_val_scaled, true_unit)
        scaled_val, unit = function_name(val)
        same = (scaled_val ≈ true_val_scaled)
        if same == true
            same = (unit == true_unit)
        end

        return same
    end



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

        @testset "format_time" begin
            using TcpInstruments: format_time
            @test expected_number_and_unit(format_time, 1e3,     1000,   "s")
            @test expected_number_and_unit(format_time, 1,          1,   "s")
            @test expected_number_and_unit(format_time, 0,          0,   "s")
            @test expected_number_and_unit(format_time, -1,        -1,   "s")
            @test expected_number_and_unit(format_time, -2e-2,    -20,  "ms")
            @test expected_number_and_unit(format_time, -3e-3,     -3,  "ms")
            @test expected_number_and_unit(format_time, -4e-4,   -400,  "µs")
            @test expected_number_and_unit(format_time, -5e-5,    -50,  "µs")
            @test expected_number_and_unit(format_time, -6e-6,     -6,  "µs")
            @test expected_number_and_unit(format_time, -7e-7,   -700,  "ns")
            @test expected_number_and_unit(format_time, -8e-8,    -80,  "ns")
            @test expected_number_and_unit(format_time, -9e-9,     -9,  "ns")
            @test expected_number_and_unit(format_time, -10e-10,   -1,  "ns")
            @test expected_number_and_unit(format_time, -11e-11, -110,  "ps")
            @test expected_number_and_unit(format_time, -12e-12,  -12,  "ps")
            @test expected_number_and_unit(format_time, -13e-13, -1.3,  "ps")
            @test expected_number_and_unit(format_time, -14e-14, -0.14, "ps")
        end


        @testset "format_volt" begin
            using TcpInstruments: format_volt
            @test expected_number_and_unit(format_volt, 1001, 1.001, "kV")
            @test expected_number_and_unit(format_volt, 1000,  1000,  "V")
            @test expected_number_and_unit(format_volt, 1.1,    1.1,  "V")
            @test expected_number_and_unit(format_volt, 0,        0,  "V")
            @test expected_number_and_unit(format_volt, 1e-1,   100, "mV")
            @test expected_number_and_unit(format_volt, 2.2e-2,  22, "mV")
            @test expected_number_and_unit(format_volt, 3.3e-3, 3.3, "mV")
            @test expected_number_and_unit(format_volt, 3.3e-6, 3.3, "µV")
            @test expected_number_and_unit(format_volt, 7.6e-9, 7.6, "nV")
        end




    end

end

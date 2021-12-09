using TcpInstruments
using Test
using TestSetExtensions
using Unitful

#using Aqua
#Aqua.test_all(TcpInstruments)

const A = u"A"

@testset ExtendedTestSet "TcpInstruments" begin

    function expected_number_and_unit(function_name, val, true_factor, true_val_scaled, true_unit)
        scaled_val, factor, unit = function_name(val)

        same = (scaled_val ≈ true_val_scaled)
        same && (same = unit == true_unit)
        same && (same = factor == true_factor)

        if !same
            @info "true"   true_val_scaled, true_factor, true_unit
            @info "scaled"      scaled_val,      factor,      unit
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

        @testset "get_nearest_scale_and_time_unit" begin
            using TcpInstruments: get_nearest_scale_and_time_unit
            @test expected_number_and_unit(get_nearest_scale_and_time_unit, 1e3,     1, 1000,   "s")
            @test expected_number_and_unit(get_nearest_scale_and_time_unit, 1,       1,    1,   "s")
            @test expected_number_and_unit(get_nearest_scale_and_time_unit, 0,       1,    0,   "s")
            @test expected_number_and_unit(get_nearest_scale_and_time_unit, -1,      1,   -1,   "s")
            @test expected_number_and_unit(get_nearest_scale_and_time_unit, -2e-2,   1e3,  -20,  "ms")
            @test expected_number_and_unit(get_nearest_scale_and_time_unit, -3e-3,   1e3,   -3,  "ms")
            @test expected_number_and_unit(get_nearest_scale_and_time_unit, -4e-4,   1e6, -400,  "µs")
            @test expected_number_and_unit(get_nearest_scale_and_time_unit, -5e-5,   1e6,  -50,  "µs")
            @test expected_number_and_unit(get_nearest_scale_and_time_unit, -6e-6,   1e6,   -6,  "µs")
            @test expected_number_and_unit(get_nearest_scale_and_time_unit, -7e-7,   1e9, -700,  "ns")
            @test expected_number_and_unit(get_nearest_scale_and_time_unit, -8e-8,   1e9,  -80,  "ns")
            @test expected_number_and_unit(get_nearest_scale_and_time_unit, -9e-9,   1e9,   -9,  "ns")
            @test expected_number_and_unit(get_nearest_scale_and_time_unit, -10e-10, 1e9,   -1,  "ns")
            @test expected_number_and_unit(get_nearest_scale_and_time_unit, -11e-11, 1e12, -110,  "ps")
            @test expected_number_and_unit(get_nearest_scale_and_time_unit, -12e-12, 1e12,  -12,  "ps")
            @test expected_number_and_unit(get_nearest_scale_and_time_unit, -13e-13, 1e12, -1.3,  "ps")
            @test expected_number_and_unit(get_nearest_scale_and_time_unit, -14e-14, 1e12, -0.14, "ps")

        end


        @testset "get_nearest_scale_and_volt_unit" begin
            using TcpInstruments: get_nearest_scale_and_volt_unit
            @test expected_number_and_unit(get_nearest_scale_and_volt_unit, 1.1e9, 1e-9, 1.1, "GV")
            @test expected_number_and_unit(get_nearest_scale_and_volt_unit, 1.2e6, 1e-6, 1.2, "MV")
            @test expected_number_and_unit(get_nearest_scale_and_volt_unit, 1001,  1e-3, 1.001, "kV")
            @test expected_number_and_unit(get_nearest_scale_and_volt_unit, 1000,     1, 1000,  "V")
            @test expected_number_and_unit(get_nearest_scale_and_volt_unit, 1.1,      1,  1.1,  "V")
            @test expected_number_and_unit(get_nearest_scale_and_volt_unit, 0,        1,    0,  "V")
            @test expected_number_and_unit(get_nearest_scale_and_volt_unit, 1e-1,   1e3,  100, "mV")
            @test expected_number_and_unit(get_nearest_scale_and_volt_unit, 2.2e-2, 1e3,   22, "mV")
            @test expected_number_and_unit(get_nearest_scale_and_volt_unit, 3.3e-3, 1e3,   3.3, "mV")
            @test expected_number_and_unit(get_nearest_scale_and_volt_unit, 3.3e-6, 1e6,   3.3, "µV")
            @test expected_number_and_unit(get_nearest_scale_and_volt_unit, 7.6e-9, 1e9,   7.6, "nV")
        end




    end

end

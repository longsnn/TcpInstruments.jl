using TcpInstruments
using Test
using TestSetExtensions
using Unitful

#using Aqua
#Aqua.test_all(TcpInstruments)

const A = u"A"

@testset ExtendedTestSet "TcpInstruments" begin

    function expected_number_and_unit(function_name, base_unit, val, true_val_scaled, true_unit; max_power = 3)
        scaled_val, unit = function_name(val; base_unit = base_unit, max_power = max_power)

        same = (scaled_val ≈ true_val_scaled)
        same && (same = unit == true_unit)

        if !same
            @info "value"   true_val_scaled, scaled_val, isapprox(scaled_val, true_val_scaled)
            @info "scaled"        true_unit,       unit, true_unit == unit
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

        @testset "convert_to_best_prefix" begin
            using TcpInstruments: convert_to_best_prefix
            @test expected_number_and_unit(convert_to_best_prefix, "s", 1e3,     1000,   "s")
            @test expected_number_and_unit(convert_to_best_prefix, "s", 1,          1,   "s")
            @test expected_number_and_unit(convert_to_best_prefix, "s", 0,          0,   "s")
            @test expected_number_and_unit(convert_to_best_prefix, "s", -1,        -1,   "s")
            @test expected_number_and_unit(convert_to_best_prefix, "s", -2e-2,     -20,  "ms")
            @test expected_number_and_unit(convert_to_best_prefix, "s", -3e-3,      -3,  "ms")
            @test expected_number_and_unit(convert_to_best_prefix, "s", -4e-4,    -400,  "µs")
            @test expected_number_and_unit(convert_to_best_prefix, "s", -5e-5,     -50,  "µs")
            @test expected_number_and_unit(convert_to_best_prefix, "s", -6e-6,      -6,  "µs")
            @test expected_number_and_unit(convert_to_best_prefix, "s", -7e-7,    -700,  "ns")
            @test expected_number_and_unit(convert_to_best_prefix, "s", -8e-8,     -80,  "ns")
            @test expected_number_and_unit(convert_to_best_prefix, "s", -9e-9,      -9,  "ns")
            @test expected_number_and_unit(convert_to_best_prefix, "s", -10e-10,    -1,  "ns")
            @test expected_number_and_unit(convert_to_best_prefix, "s", -11e-11,  -110,  "ps")
            @test expected_number_and_unit(convert_to_best_prefix, "s", -12e-12,   -12,  "ps")
            @test expected_number_and_unit(convert_to_best_prefix, "s", -13e-13,  -1.3,  "ps")
            # test going outside the unit prefix array size
            @test expected_number_and_unit(convert_to_best_prefix, "s", -14e-14, -0.14,  "ps")
            @test expected_number_and_unit(convert_to_best_prefix,  "s",  14e14, 1.4e6,  "Gs")
            @test expected_number_and_unit(convert_to_best_prefix,  "s",  14e14, 14e14,  "s"; max_power=0)

            # volt unit
            @test expected_number_and_unit(convert_to_best_prefix, "V", 1.1e9,   1.1,  "GV")
            @test expected_number_and_unit(convert_to_best_prefix, "V", 7.6e-9,   7.6, "nV")

            # with units
            @test convert_to_best_prefix(1100u"V") ≈ 1.1u"kV"
            @test convert_to_best_prefix(0u"V") ≈ 0u"V"
            @test convert_to_best_prefix(1u"V") ≈ 1u"V"
            @test convert_to_best_prefix(1000u"V") ≈ 1000u"V"
            @test convert_to_best_prefix(11e-11u"s") ≈ 110u"ps"
            @test convert_to_best_prefix(12e-12u"V") ≈ 12u"pV"
            @test convert_to_best_prefix(13e-13u"V") ≈ 1.3u"pV"

            @test convert_to_best_prefix(-1000u"V")   ≈ -1000u"V"
            @test convert_to_best_prefix(-11e-11u"s") ≈ -110u"ps"
            @test convert_to_best_prefix(-12e-12u"V") ≈ -12u"pV"
            @test convert_to_best_prefix(-13e-13u"V") ≈ -1.3u"pV"
        end


        @testset "new_autoscale_unit" begin
            using TcpInstruments: new_autoscale_unit
            no_unit = rand(100)
            before = 2001u"V"*no_unit
            true_scale = 2.001u"kV"*no_unit
            after = new_autoscale_unit(before)
            @test after ≈ true_scale


        end


        @testset "show(ScopeData)" begin
            using TcpInstruments: ScopeInfo, ScopeData
            si = ScopeInfo("8bit", "Normal", 1000, 1/1e3, -5e-4, 0, 1, 0, 0, "50 Ω", "DC", "off", 2)
            amplitude = 100u"mV"
            volts = amplitude* TcpInstruments.fake_signal(si.num_points; f0=7.5e6)
            mytime = u"s"*((( collect(0:(si.num_points-1))  .- si.x_reference) .* si.x_increment) .+ si.x_origin)
            sd = ScopeData(si, volts, mytime)
            println("")
            show(sd)

        end


    end

end

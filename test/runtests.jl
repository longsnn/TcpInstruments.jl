using TcpInstruments
using Test
using TestSetExtensions
using Unitful

#using Aqua
#Aqua.test_all(TcpInstruments)

const A = u"A"

@testset ExtendedTestSet "TcpInstruments" begin
    @testset "Fake Scope" begin
        f = initialize(TcpInstruments.FakeDSOX4034A)

        @testset "Test waveform info" begin
            waveform_info = get_waveform_info(f, 1)
            @test waveform_info.num_points == f.model.num_samples
        end

        @testset "Save single ch data" begin
            data = get_data(f, 1)
            @test data isa TcpInstruments.ScopeData
            @test length(data.time) == length(data.volt)
            @test data.volt[1] isa Unitful.Voltage

            time_no_units = TcpInstruments.raw.(data.time)
            volt_no_units = TcpInstruments.raw.(data.volt)
            time_unit = string(unit(data.time[1]))
            volt_unit = string(unit(data.volt[1]))

            save_filename = "./single_ch_scope_data"
            save(data, filename=save_filename, format=:matlab)
            data_loaded = load(save_filename * ".mat")
            for key in keys(data_loaded["info"])
                @test data_loaded["info"][key] == getproperty(data.info, Symbol(key))
            end
            @test data_loaded["time"] == time_no_units
            @test data_loaded["volt"] == volt_no_units
            @test string(data_loaded["time_unit"]) == time_unit
            @test string(data_loaded["volt_unit"]) == volt_unit
            rm(save_filename * ".mat")
        end

        @testset "Save multi ch data" begin
            data = get_data(f, [1,2,3,4])
            @test length(data) == 4
            
            save_filename = "./multi_ch_scope_data"
            save(data, filename=save_filename, format=:matlab)
            
            data_loaded = load(save_filename * ".mat")
            for idx = 1:length(data)
                pre_save_data = data[idx]
                post_save_data = data_loaded["channel_$(idx)"]
                for key in keys(post_save_data["info"])
                    @test post_save_data["info"][key] == getproperty(pre_save_data.info, Symbol(key))
                end
                @test post_save_data["time"] == ustrip.(pre_save_data.time)
                @test post_save_data["volt"] == ustrip.(pre_save_data.volt)
                @test string(post_save_data["time_unit"]) == string(unit(pre_save_data.time[1]))
                @test string(post_save_data["volt_unit"]) == string(unit(pre_save_data.volt[1]))
            end
            rm(save_filename * ".mat")
        end
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

        @testset "Save to Matlab file" begin
            data = randn(100)u"V"
            data_nounit = ustrip(data)

            # save unitful input
            filename_1 = "./testfile_1"
            save(data, filename=filename_1, format=:matlab)
            data_loaded_1 = load(filename_1 * ".mat")
            @test data_loaded_1["data"] == data_nounit
            rm(filename_1 * ".mat")

            # save non-unitful input (numbers)
            filename_2 = "./testfile_2"
            save(data_nounit, filename=filename_2, format=:matlab)
            data_loaded_2 = load(filename_2 * ".mat")
            @test data_loaded_2["data"] == data_nounit
            rm(filename_2 * ".mat")

            # save non-unitful input (string)
            val = "not unitful, and not a number"
            filename_3 = "./testfile_3"
            save(val, filename=filename_3, format=:matlab)
            data_loaded_3 = load(filename_3 * ".mat")
            @test data_loaded_3["data"] == val
            rm(filename_3 * ".mat")
        end
    end
end

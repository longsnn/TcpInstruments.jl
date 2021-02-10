module TcpInstruments

using Printf
using RecipesBase
using Sockets

export 
        Instrument,
        Oscilloscope, 
        MultiMeter,
        PowerSupply,
        WaveformGenerator,
        ImpedanceAnalyzer,
        GenericInstrument,

        initialize,
        terminate,
        reset!,
        connect!,
        close!,
        lock!,
        unlock!,
        query,
        write,
        info,


        # Power Supply
        enable_output!,
        disable_output!,
        get_output,
        set_current_limit!,
        get_current_limit,
        set_voltage!,
        get_voltage,
        set_voltage_limit!,
        get_voltage_limit,
        set_channel!,
        get_channel,

        # Scope
        run!,
        stop!,
        get_data,
        lpf_on!,
        lpf_off!,
        get_lpf_state,
        set_impedance_one!,
        set_impedance_fifty!,
        get_impedance,
        get_coupling,
        get_function,
        set_function!,
        get_frequency,
        set_frequency!,
        get_amplitude,
        set_amplitude!,
        get_voltage_offset,
        set_voltage_offset!,
        get_burst_mode,
        get_mode,
        set_mode_burst!,
        set_mode_cw!,
        set_burst_mode_gated!,
        set_burst_mode_triggered!,


        # Prologix
        set_prologix_chan!,
        get_prologix_chan,
        scan_prologix,


        # DMM
        get_tc_temperature,
        set_tc_type,
        get_volt,
        get_amp,
        set_temp_celsius,
        set_temp_farenheit,
        set_temp_kelvin,

        # Devices
        ## Impedance Analyzer
        Agilent4294A,
        Agilent4395A,
        ## Multimeter
        #KeysightDMM34465A,
        ## Scope
        AgilentDSOX4024A,
        AgilentDSOX4034A,
        ## Power Supply
        AgilentE36312A,
        BenchXR,
        SRSPS310,
        ## Waveform Generator
        Keysight33612A,


        instrument_reset,
        instrument_clear,
        instrument_get_id,
        instrument_beep_on,
        instrument_beep_off,
        instrument_set_hilevel


include("util.jl")
include("config.jl")

# common instrument containers
include("instr.jl")
include("instrument.jl")
include("common_commands.jl")

# instruments
include("scope/scope.jl")
include("psu/psu.jl")
include("awg/awg.jl")
include("ia/ia.jl")
#include("dmm/dmm.jl")

init_tcp_yaml()
end #endmodule

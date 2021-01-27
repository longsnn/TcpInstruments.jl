module TcpInstruments

export 
        Instrument,
        Oscilloscope, 
        MultiMeter,
        PowerSupply,
        WaveformGenerator,
        GenericInstrument,
        connect!,
        close!,


        initialize,
        terminate,
        instrument_reset,
        instrument_clear,
        instrument_get_id,
        instrument_beep_on,
        instrument_beep_off,
        # Scope specific commends
        scope_get_ch_data,

        # Devices // could also be mapped to symbol names
        # to avoid exporting
        KeysightDSOX4024A,
        KeysightDSOX4034A,
        Keysight33612A


# common instrument containers
include("instrument.jl")
include("common_commands.jl")

# instruments
include("scope/scope.jl")
#include("psu/psu.jl")
#include("awg/awg.jl")
#include("dmm/dmm.jl")

end #endmodule

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

        instrument_initialize,
        instrument_reset,
        instrument_clear,
        instrument_get_id,
        instrument_beep_on,
        instrument_beep_off,
        # Scope specific commends
        scope_get_ch_data



# common instrument containers
include("instrument.jl")
include("common_commands.jl")

# instruments
include("scope/scope.jl")
#include("psu/psu.jl")
#include("awg/awg.jl")
#include("dmm/dmm.jl")

end #endmodule

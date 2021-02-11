include("scope_common.jl")

struct AgilentDSOX4024A <: Oscilloscope end
struct AgilentDSOX4034A <: Oscilloscope end

#const SignalGenAndScope = Union{AgilentDSOX4024A, Keysight33612A}

run(obj::Instr{AgilentDSOX4034A})    = scope_continue(obj)
stop(obj::Instr{AgilentDSOX4034A})    = scope_stop(obj)

# Priority 1 when defined
#instrument_reset(obj::Instr{AgilentDSOX4024A})    = write(obj, "*RST for 402")
# Priority 2
#instrument_reset(obj::Instr{T}) where (T <: SignalGenAndScope)   = write(obj, "*RST for SpecialGroup")
# Priority 3
#instrument_reset(obj::Instr{T}) where (T <: Oscilloscope)   = write(obj, "*RST for Oscilloscope")

#instrument_reset(obj::Instr{AgilentDSOX4034A})    = write(obj, "*RST for 403")

# Include model specific files here


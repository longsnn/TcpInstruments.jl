module TcpInstruments

# common instrument containers
include("INSTR_TYPES.jl")
# instruments
include("psu/PSU.jl")
include("awg/AWG.jl")
include("scope/SCOPE.jl")
include("dmm/DMM.jl")

end #endmodule

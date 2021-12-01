
# common_commands.jl

# instrument.jl
precompile(initialize, (Type{AgilentDSOX4034A},))
precompile(initialize, (Type{VersatilePower},))
precompile(initialize, (Type{Keysight33612A},))

precompile(get_data, (Type{AgilentDSOX4034A}, Int64))
precompile(get_data, (Type{AgilentDSOX4024A}, Int64))

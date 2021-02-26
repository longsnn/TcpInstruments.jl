using TcpInstruments
using Test

s = initialize(AgilentDSOX4034A)

for i in 1:2
@info "Single Test $i"

@info "Single Channel"
@time get_data(s, 1)

@info "Single Channel in Array; Forgo Inbounds False"
@time get_data(s, [1])

@info "Single Channel in Array; Forgo Inbounds True"
@time get_data(s, [1]; inbounds=true)



@info "Two Channel Test $i"

@info "Two Channel Explicit; Inbounds False"
@time get_data(s, [1, 2])

@info "Two Channel Autosearch; Inbounds False"
@time get_data(s)

@info "Two Channel Explicit; Forgo Inbounds Checking: True"
@time get_data(s, [1, 2]; inbounds=true)

@info "Two Channel Autosearch; Forgo Inbounds Checking: True"
@time get_data(s; inbounds=true)
end

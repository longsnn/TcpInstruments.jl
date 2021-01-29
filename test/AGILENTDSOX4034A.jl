using TcpInstruments
using Test

@info "Creating dummy instrument at 10.1.30.32"
#scope = initialize(AgilentDSOX4034A,  "10.1.30.32")
scope = GenericInstrument(:dummy, "10.1.30.32")
connect!(scope)


"""
Spec:

> scope_h = initialize("192.168.1.15")

Grab data from channel 1
> data_struct = get_data(scope_h, 1)

Grab data from channel 2 and 4
> data_struct = get_data(scope_h, [2,4])

Terminate TCP connection
> terminate(scope_h)
"""

@info reset!(scope)
data = get_data(scope, 1)
@test !isempty(data.volt)
@test !isempty(data.time)

# plot(data)

data2 = get_data(scope, [2,4])
@info typeof(data2)
@test terminate(scope)  == false
@info "Successfully disconnected"
@info "Goodbye"

using TcpInstruments
using Test

scope = initialize(AgilentDSOX4034A)
@info "Successfully connected $(scope.model) at $(scope.address)"


"""
Spec:

> scope_h = initialize("192.168.1.15")

Grab data from channel 1
> data_struct = get_data(scope_h, 1)

Grab data from channel 2 and 4
> data_struct = get_data(scope_h, [2,4])

Low Pass Filter
Turn on Low Pass Filter 25
> lpf_on(scope)

Check if low pass filter is on
> get_lpf_state(scope) == "1"

Turn on Low Pass Filter 25MHz
> lpf_off(scope)
> get_lpf_state(scope) == "0"

Impedance

> set_impedance_one(scope_h)

> get_impedance(scope_h) == ONEM

> set_impedance_fifty(scope_h)

> get_impedance(scope_h) == FIFT

Terminate TCP connection
> terminate(scope_h)


"""

data = get_data(scope, 1)

data2 = get_data(scope, [1,2])
@info typeof(data2)

@test !isempty(data.volt)
@test !isempty(data.time)

@info get_lpf_state(scope)
lpf_on(scope)
@info get_lpf_state(scope)
lpf_off(scope)
@info get_lpf_state(scope)

@info get_impedance(scope)
set_impedance_one(scope)
@info get_impedance(scope)
set_impedance_fifty(scope)
@info get_impedance(scope)


# plot(data)

terminate(scope)
@info "Successfully disconnected"
@info "Goodbye"

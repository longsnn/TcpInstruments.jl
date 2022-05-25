using TcpInstruments
using Test

m = initialize(KeysightDMM34465A, "10.1.30.36" )

V = get_voltage(m, "DC", "1", "1")
@info get_voltage V
@test V isa Float64

V = get_voltage(m, "AC", "1")
@info get_voltage V
@test V isa Unitful.Voltage

A = get_current(m)
@info get_current A
@test A isa Float64

Ω = get_resistance(m; wire=2)
@info "get_resistance(; wire=2)" Ω
@test Ω isa Float64

Ω = get_resistance(m; wire=4)
@info "get_resistance(; wire=4)" Ω
@test Ω isa Float64

channel = get_channel(m)
@info get_channel channel
@test channel in ["FRON", "REAR"]

@info "°" get_tc_temperature(m) get_temp_unit(m)

set_temp_unit_kelvin(m)

@info get_tc_temperature(m) get_temp_unit(m)

# set_tc_type(m; type="K")

set_temp_unit_farenheit(m)

@info get_tc_temperature(m) get_temp_unit(m)

set_temp_unit_celsius(m)

@info get_tc_temperature(m) get_temp_unit(m)

terminate(m)

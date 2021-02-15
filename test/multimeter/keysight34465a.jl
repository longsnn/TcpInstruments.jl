using TcpInstruments
using Test

m = initialize(KeysightDMM34465A)

@info "V" get_voltage(m)

@info "A" get_current(m)

@info "Ω" get_resistance(m; wire=2)

@info "Ω" get_resistance(m; wire=4)

@info "°" get_tc_temperature(m) get_temp_unit(m)

set_temp_unit_kelvin(m)

@info get_tc_temperature(m) get_temp_unit(m)

# set_tc_type(m; type="K")

set_temp_unit_farenheit(m)

@info get_tc_temperature(m) get_temp_unit(m)

set_temp_unit_celsius(m)

@info get_tc_temperature(m) get_temp_unit(m)

terminate(m)

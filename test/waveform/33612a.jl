using TcpInstruments
using Test

w = write
q = query

wg = initialize(Keysight33612A)
@info "Successfully connected $(wg.model) at $(wg.address)"

@info get_output(wg)
enable_output(wg)
@test get_output(wg) == true
disable_output(wg)
@test get_output(wg) == false

write(wg, "SOURce1:APPLy:SIN MAX")
"""
initialize() X
terminate() X
enable_output() X
disable_output() X
get_output() X
{set,get}_frequency() X
{set,get}_amplitude() X
{set,get}_burst_num_cycles() X
{set,get}_time_offset()
{set,get}_voltage_offset() X
{set,get}_burst_period() X
set_mode_burst() X
set_mode_cw() X

get_mode() X
"""

"""
FUNCtion SIN
FREQ 1e4
VOLT 1
VOLT:OFF 0.1
OUTP ON
"""

@info get_function(wg)
set_function(wg, "SIN")
@info get_function(wg)

@info get_frequency(wg)
set_frequency(wg, "1e3")
@info get_frequency(wg)

@info get_amplitude(wg)
set_amplitude(wg, 0.1)
@info get_amplitude(wg)
@info typeof(get_amplitude(wg))

@info get_voltage_offset(wg)
set_voltage_offset(wg, 0)
@info get_voltage_offset(wg)
enable_output(wg)

"""
@info get_burst_mode(wg) 
@info get_mode(wg)
set_burst_mode_gated(wg)
@info get_burst_mode(wg) 
@info get_mode(wg)
set_mode_burst(wg)
@info get_burst_mode(wg) 
@info get_mode(wg)
set_burst_mode_gated(wg)
@info get_burst_mode(wg) 
@info get_mode(wg)
"""

set_mode_cw(wg)
w(wg, "TRIGger1:SOURce TIMer")
set_mode_burst(wg)
set_mode_cw(wg)
set_function(wg, "SQU")
enable_output(wg)

@info get_function(wg; chan=2)
set_function(wg, "SIN"; chan=2)
@info get_function(wg; chan=2)

@info get_frequency(wg; chan=2)
set_frequency(wg, "1e3"; chan=2)
@info get_frequency(wg; chan=2)

@info get_amplitude(wg; chan=2)
set_amplitude(wg, 0.1)
@info get_amplitude(wg)
@info typeof(get_amplitude(wg))

@info get_voltage_offset(wg)
set_voltage_offset(wg, 0)
@info get_voltage_offset(wg)
enable_output(wg)

#@info q(wg, "CHAN?"), "SOURCE"
terminate(wg)
@info "Thanks"

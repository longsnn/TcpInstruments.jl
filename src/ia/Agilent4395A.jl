"""

# Available functions
- `initialize()`
- `terminate()`
- `get_frequency_limits()`
- `get_amplitude_limits()`
- `get_num_data_points(x)`
- `set_frequency_limits()`
- `set_amplitude_limits()`
- `set_num_data_points(x)`
- `get_impedance_spectrum()`

"""
struct Agilent4395A <: PowerSupply end

get_frequency_limits(obj) = write(obj, "")
set_frequency_limits(obj, num) = query(obj, "")

get_amplitude_limits(obj) = write(obj, "")
set_amplitude_limits(obj, num) = query(obj, "")

get_num_data_points(obj, num) = write(obj, "")
set_num_data_points(obj, num) = query(obj, "")

get_impedance_spectrum(obj) = write(obj, "")

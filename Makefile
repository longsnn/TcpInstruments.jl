e: # Emulate
	julia --project=. test/emulate/fake_device.jl
t: # Test
	julia --project=. test/emulate/test_fake_device.jl
c: # Console
	julia --project=.
s: # Scope
	julia --project=. test/scope/agilent_dsox4034a.jl
p: # Power Supply
	julia --project=. test/pwr/agilent_e36312a.jl
x: # Power Supply
	julia --project=. test/pwr/bench_xr.jl
w: # Waveform
	julia --project=. test/waveform/33612a.jl

plot:
	julia --project=. test/test_plot.jl





e: # Emulate
	julia test/fake_scope.jl
t: # Test
	julia test/dummy_instrument.jl
c: # Console
	julia --project=.
s: # Scope
	julia --project=. test/AGILENTDSOX4034A.jl
p: # Power Supply
	julia --project=. test/power_supply.jl
plot:
	julia --project=. test/test_plot.jl

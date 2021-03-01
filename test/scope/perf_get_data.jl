using TcpInstruments
using Test

s = initialize(AgilentDSOX4034A)

timeit(func_time, title) = println("$title: $(func_time)")

for i in 1:2
println("Single Channe: Iteration $i")

@show @elapsed get_data(s, 1)

@show @elapsed get_data(s, [1])

@show @elapsed get_data(s, [1]; inbounds=true)


println("Two Channel Test: Iteration $i")

@show @elapsed get_data(s, [1, 2])

@show @elapsed get_data(s)

@show @elapsed get_data(s, [1, 2]; inbounds=true)

@show @elapsed get_data(s; inbounds=true)
end

using Sockets
using Base.Threads: @spawn
using Dates

function elapsed_time(start_time)
            seconds = floor(time() - start_time)
            return Time(0) + Second(seconds)
end

function elapsed_time(func, start_time)
            seconds = floor(time() - start_time)
            return Time(0) + Second(func(seconds))
end

"""
    scan_network(; ip_network="10.1.30.", ip_range=1:255, v=false)
Will scan your network and report all found devices.

By default it only searches for devices connected on port: 5025

If you would like to search for devices on a different port set the
v flag to true.
"""
function scan_network(; ip_network="10.1.30.", ip_range=1:255, v=false)
    @info "Scanning $ip_network$(ip_range[1])-$(ip_range[end])"
    ips = asyncmap(
        x->connect_to_scpy(x; v=v),
        [ip_network*"$ip" for ip in ip_range]
    )
    return [s for s in ips if !isempty(s)]
end

function connect_to_scpy(ip_str; v=false)
    scpy_port = 5025
    temp_ip = ip_str * ":$scpy_port"
    proc = @spawn temp_ip => info(initialize(Instrument, temp_ip))
    sleep(2)
    if proc.state == :runnable
        schedule(proc, ErrorException("Timed out"), error=true)
        return ""
    elseif proc.state == :done
        return fetch(proc)
    elseif proc.state == :failed
        v && return ip_str * ":????"
        return ""
    else
        error("Undefined $(proc.state)")
    end
end

udef(func) =  error("$(func) not implemented")

macro codeLocation()
           return quote
               st = stacktrace(backtrace())
               myf = ""
               for frm in st
                   funcname = frm.func
                   if frm.func != :backtrace && frm.func!= Symbol("macro expansion")
                       myf = frm.func
                       break
                   end
               end
               println("Running function ", $("$(__module__)"),".$(myf) at ",$("$(__source__.file)"),":",$("$(__source__.line)"))
               
               myf
           end
       end

function alias_print(msg)
    printstyled("[ Aliasing: ", color = :blue, bold = true)
    println(msg)
end

"""
	split_str_into_host_and_port(str)
Splits a string like "192.168.1.1:5056" into ("192.168.1.1", 5056)
"""
function split_str_into_host_and_port(str::AbstractString)::Tuple{String, Int}
	spl_str = split(str, ":")
	@assert !isempty(spl_str) "IP address string is empty!"
	host = spl_str[1]
	if length(spl_str) == 1
		port = 0
	else
		port = parse(Int, spl_str[2])
	end
	return (host, port)
end

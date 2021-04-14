using Sockets
using Base.Threads: @spawn
using Dates
using MAT
using JLD2

const R = u"Ω"
const V = u"V"
const A = u"A"
const Hz = u"Hz"

using Unitful: Current, Voltage, Frequency, Time

raw(a::Current)   = Float64(ustrip(uconvert(A, a)))
raw(a::Voltage)   = Float64(ustrip(uconvert(V, a)))
raw(a::Frequency) = Float64(ustrip(uconvert(Hz, a)))
raw(a::Time)      = Float64(ustrip(uconvert(u"s", a)))

function elapsed_time(start_time)
    seconds = floor(time() - start_time)
    return Time(0) + Second(seconds)
end

function elapsed_time(func, start_time)
    seconds = floor(time() - start_time)
    return Time(0) + Second(func(seconds))
end

"""
    save(data)
    save(data; format=:matlab)
    save(data; filename="custom_file_name.ext")

Save data to a file

By default saves to julia format (.jld2) but can also export
data to matlab by using the format=:matlab keyword argument
"""
function save(data; filename = "", format = :julia)
    if isempty(filename)
        t = Dates.format(Dates.now(), "yy-mm-dd_HH:MM:SS")
        filename = "scan_" * t
    end
    if format == :julia
        @save (filename * ".jld2") data
    elseif format == :matlab
        if isa(data, ScopeData)
            data = ScopeData(data.info, ustrip(data.volt), data.time)
        end
        file = matopen(filename * ".mat", "w")
        write(file, "data", data)
        close(file)
    end
end

"""
    data = load("file.jld2")

Loads saved data from a file
"""
function load(filename)
    ext = split(filename, '.')[end]
    if ext == "jld2"
        jldopen(filename)["data"]
    else
        error("unsupported file type: $ext")
    end
end

"""
    scan_prologix(ip::AbstractString)

Given an IP Address to a prologix adapter return a
Dict of GPIB bus numbers that map to the connected device names
"""
function scan_prologix(ip::AbstractString)
    instr = initialize(Instrument, ip)
    return scan_prologix(instr)
end

"""
    scan_prologix(instr)

Given any instrument with a connection to a prologix adapter that
supports query and write. Return a Dict of GPIB bus numbers
that map to the connected device names
"""
function scan_prologix(obj)
    devices = Dict()
    for i in 0:15
        write(obj, "++addr $i")
        try
            devices[i] = query(obj, "*IDN?"; timeout = 0.5)
        catch

        end
    end
    return devices
end

"""
    scan_network(; network_id="10.1.30.0", host_range=1:255, v=false)
Will scan your network and report all found devices.

By default it only searches for devices connected on port: 5025

If you would like to search for devices on a different port set the
v flag to true.
"""
function scan_network(; network = "10.1.30.0", host_range = 1:255, v = false)
    @info "Scanning $(network[1:end-1])$(host_range[1])-$(host_range[end])"
    ips = asyncmap(
        x -> connect_to_scpy(x; v = v),
        [network[1:end-1] * "$host" for host in host_range],
    )
    return [s for s in ips if !isempty(s)]
end

function connect_to_scpy(ip_str; v = false)
    scpy_port = 5025
    temp_ip = ip_str * ":$scpy_port"
    proc = @spawn temp_ip => info(initialize(Instrument, temp_ip))
    sleep(2)
    if proc.state == :runnable
        schedule(proc, ErrorException("Timed out"), error = true)
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

udef(func) = error("$(func) not implemented")

macro codeLocation()
    return quote
        st = stacktrace(backtrace())
        myf = ""
        for frm in st
            funcname = frm.func
            if frm.func != :backtrace && frm.func != Symbol("macro expansion")
                myf = frm.func
                break
            end
        end
        println(
            "Running function ",
            $("$(__module__)"),
            ".$(myf) at ",
            $("$(__source__.file)"),
            ":",
            $("$(__source__.line)"),
        )

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
function split_str_into_host_and_port(str::AbstractString)
	spl_str = split(str, ":")
    isempty(spl_str) && error("IP address string is empty!")
    host = spl_str[1]
    if length(spl_str) == 1
        port = 0
    else
        port = parse(Int, spl_str[2])
    end
    return (host, port)
end

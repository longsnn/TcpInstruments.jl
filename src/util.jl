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
        filename = "InstrumentData_" * t
    end
    if format == :julia
        @save (filename * ".jld2") data
    elseif format == :matlab
        file = matopen(filename * ".mat", "w"; compress=true)
        if isa(data, ScopeData)
            info = data.info
            volt = ustrip.(data.volt)
            time = ustrip.(data.time)
            write(file, "info", info)
            write(file, "volt", volt)
            write(file, "time", time)
        else
            write(file, "data", raw.(data))
        end

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
        data = jldopen(filename)["data"]
    elseif ext == "mat"
         data = matread(filename)["data"]
    else
        error("unsupported file type: $ext")
    end

    return data
end


"""
    scan_network(; network_id="10.1.30.0", host_range=1:255)

By default, report all found devices between addresses `10.1.30.1` to `10.1.30.255`.

Searches for devices connected on port:
- 5025 (scpi)
- 1234 (prologix)
"""
function scan_network(; network="10.1.30.", host_range=1:255)
    network = ensure_ending_dot(network)
    @info "Scanning $network$(host_range[1])-$(host_range[end])"

    # Scan for SCPI devices
    println("Scanning for SCPI devices")
    ips_scpi = asyncmap(x-> _get_info_from_ip(x), [network*"$ip" for ip in host_range])
    println("")

    # Scan for Prologix device
    println("Scanning for Prologix devices")
    ips_prlx = asyncmap(x-> _get_info_from_ip(x; port=1234), [network*"$ip" for ip in host_range])

    ips_all = vcat(ips_scpi, ips_prlx)
    print("\n")
    return [ip for ip in ips_all if !isempty(ip)]
end
ensure_ending_dot(network) = network[end] != '.' ? network*'.' : network

function _get_info_from_ip(ip_str; port = 5025)
    temp_ip = ip_str * ":$port"
    proc = @spawn temp_ip => _get_instr_info_and_close(temp_ip)
    sleep(2)
    if proc.state == :runnable
        print("t") # for time out
        kill_task(proc)
        return ""
    elseif proc.state == :done
        printstyled("s"; color = :green) # for success
        return fetch(proc)
    elseif proc.state == :failed
        print("f") # for failed
        return ""
    else
        error("Uncaught state: $(proc.state)")
    end
end

kill_task(proc) = schedule(proc, ErrorException("Timed out"), error=true)

function _get_instr_info_and_close(ip)

    obj = initialize(Instrument, ip)
    info_str = info(obj)
    terminate(obj)
    return info_str
end

"""
    scan_prologix(ip::AbstractString)
    Scans all GPIB addresses on a prologix device having the ip-address `ip`.
"""
function scan_prologix(ip::AbstractString)
    devices = Dict()
    prologix_port = ":1234"
    full_ip = ip * prologix_port
    obj = initialize(Instrument, ip)

    for i in 0:15
        write(obj, "++addr $i")
        try
            devices[i] = query(obj, "*IDN?"; timeout=0.5)
        catch

        end
    end
    return devices
end


udef(func) =  error("$(func) not implemented")

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





const _time_units = ["s", "ms", "µs", "ns", "ps"]
const _volt_small_units = ["V","mV", "µV", "nV"]
const _volt_large_units = ["V", "kV", "MV", "GV"]


format_time(seconds) = get_nearest_scale_and_unit(seconds, ["s"], _time_units)
format_volt(volt)    = get_nearest_scale_and_unit(volt, _volt_large_units, _volt_small_units)


function get_nearest_scale_and_unit(value, units_large, units_small)
    if value == 0 || value == 1
        return (value, units_large[1])
    end
    factor = Int(1000)
    logval = log(abs(value))
    scale_up = sign(logval) == 1
    unit_idx = ceil(Int, abs(logval) / log(factor))
    unit, unit_idx = get_nearest_unit(unit_idx, scale_up, units_large, units_small)
    scaled_value, unit_idx = scale(value, unit_idx, scale_up)

    return scaled_value, unit
end


function get_nearest_unit(unit_idx, scale_up, units_large, units_small)
    if scale_up
        unit_idx = clamp(unit_idx, 0, length(units_large))
        unit = units_large[unit_idx]
    else
        unit_idx = clamp(unit_idx+1, 1, length(units_small))
        unit = units_small[unit_idx]
    end

    return unit, unit_idx
end


function scale(value, unit_idx, scale_up)
    factor = Int(1000)
    if scale_up
        scaled_value = value/factor^(unit_idx-1)
    else
        scaled_value = value*factor^(unit_idx-1)
    end
    return scaled_value, unit_idx
end

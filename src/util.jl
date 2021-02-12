using Sockets
using Base.Threads: @spawn

struct TimeoutError <: Exception
    var::String
end


function scan_network()
    devices = []
    chnl = Channel(producer);

    it_network = "10.1.30"
    ip_range = 1:255
    ip_range = 30:40
# asyncmap?
    for ip in ip_range
        ip_str = it_network * ".$ip"
        begin
            try
                found_addr = connect_to_scpy(ip_str)
                @info found_addr
                push!(devices, found_addr)
            catch err
                if err isa InterruptException
                    return
                elseif err isa TimeoutError
                    continue
                end
                println("connection ended with error $err")
            end
        end
    end
    return devices
end



function connect_to_scpy(ip_str)
    scpy_port = 5025
    proc = @spawn connect(ip_str, scpy_port)
    sleep(1)
    if proc.state == :runnable
        schedule(proc, ErrorException("Query timed out"), error=true)
        throw(TimeoutError("Timed out after 1 second"))
    elseif proc.state == :done
        return ip_str * ":5025"
    elseif proc.state == :failed
        return ip_str * ":?"
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




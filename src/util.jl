using Sockets
using Base.Threads: @spawn

function scan_network(; ip_network="10.1.30.", ip_range=1:255)
    ips = asyncmap(
        x->connect_to_scpy(x),
        [ip_network*"$ip" for ip in ip_range]
    )
    return [s for s in ips if !isempty(s)]
end



function connect_to_scpy(ip_str)
    scpy_port = 5025
    proc = @spawn connect(ip_str, scpy_port)
    sleep(1)
    if proc.state == :runnable
        schedule(proc, ErrorException("Query timed out"), error=true)
        ""
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




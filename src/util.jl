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


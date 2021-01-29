using Sockets
import Base.Threads.@spawn

println("Orchid Emulator")
port = 8080
println("port: ", port)
server = listen(port)

tcp(msg) = printstyled("[ TCP: " * msg * "\n", color = :blue, bold = true) 

kill = false
function close_emulator()
    global kill
    kill = true
end

function emulator()
    while true
        global kill
        conn = accept(server)
        @async begin
          try
         while true
                if kill
                    exit()
                end
                line = readline(conn)
                if !isempty(line)
                    if line == "*IDN?"
                        write(conn, "1\n")
                        tcp("1")
                    else
                        tcp(line)
                    end
                end
                sleep(0.0001)
            end
          catch err
            print("connection ended with error $err")
          end
        end
    end
end

if PROGRAM_FILE == "test/fake_scope.jl"
    emulator()
else
    @spawn emulator()
end

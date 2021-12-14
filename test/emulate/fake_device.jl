using Sockets
import Base.Threads.@spawn

println(PROGRAM_FILE)
println("Instruments Emulator")
const PORT = 8080
println("port: ", PORT)
const SERVER = listen(PORT)

#tcp(msg) = printstyled("[ TCP: " * msg * "\n", color = :blue, bold = true)
tcp(msg) = []

const CONNECTION_OPEN = [true]
get_connection_open() = CONNECTION_OPEN[1]
set_connection_open(state::Bool) = CONNECTION_OPEN[1] = state
connection_is_open() = get_connection_open()
connection_is_closed() = !get_connection_open()
close_emulator() = set_connection_open(false)

function emulator()
    while true
        #@info "Accepting a TCP connection"
        conn = accept(SERVER)
        @async begin
            try
                while connection_is_open()
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

if PROGRAM_FILE == "test/emulate/fake_device.jl"
    emulator()
else
    @spawn emulator()
end

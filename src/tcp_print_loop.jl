# TCP test
using Sockets
server = listen(18080)
@info server
while true
    conn = accept(server)
    @info conn
    @async begin
    try
        while true
        line = readline(conn)
        println(line)
        #write(conn,line)
        end
    catch err
        print("connection ended with error $err")
    end
    end
end

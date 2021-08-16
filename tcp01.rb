require 'socket'

itime = Time.now
print "Initialization time is ", itime, "\n"

server = TCPServer.new 8086

loop do
  conn = server.accept
  addr = conn.peeraddr[3]
  time = Time.now

  print "Connection accepted from ", addr, " at ", time, "\n"

  conn.puts time
  conn.close
end

server.close

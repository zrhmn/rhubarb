require 'socket'

puts "Initialization time is #{Time.now()}"

TCPServer.open(8086) do |server|
  puts "Server is now listening on port #{server.addr[1]}"
  while conn = server.accept()
    time = Time.now()

    puts "Connection accepted "\
         "from #{conn.peeraddr[3]} "\
         "at #{time.strftime('%F %T (%Z)')}"

    conn.puts time.gmtime().strftime('%FT%Tz')
    conn.close()
  end
end

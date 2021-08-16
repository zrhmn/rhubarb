require 'socket'

puts "Initialization time is #{Time.now()}"

TCPServer.open('127.0.0.1', 8086) { |server|
  puts "Server is now listening on port #{server.addr[2]}"
  while conn = server.accept
    time = Time.now()

    puts "Connection accepted "\
         "from #{conn.peeraddr[3]} "\
         "at #{time.strftime('%F %T (%Z)')}"

    conn.puts time.gmtime().strftime('%FT%Tz')
    conn.close()
  end

  server.close
}

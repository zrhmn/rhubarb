# First TCP Server

See **[ENCLOSED](#enclosed)** at the bottom.

The program we are writing implements a simple TCP server that tells time.
Any TCP client can connect to our server (provided the network allows a path
from them to our server) and our server will just send the current time on
server in a standard (ISO 8601) format.

There are many practical applications of such a server, for example
synchronizing many computers on a network to the same clock. In fact, several
protocols exist (other than the simple TCP scheme we are using) dedicated to
synchronizing time. The most common one, **SNTP** ([Simple Network Time
Protocol][6]) even accounts for things like the time it takes for packets to
travel between a client to the SNTP server, natural clock skew of timekeeping
hardware etc.

We won't be doing any of that in this example.

### EXECUTION

To run the server:

```sh
$ ruby ./tcp01.rb
```

For the client, we will be using a popular, multi-purpose TCP client called
[`netcat`][7] ([see here](#consideration-netcat)). In the simplest use case,
it takes 2 arguments, first one being the network address (hostname or IP
address) and the second one being the port number. Once executed, it creates a
TCP connection to the given address.

You can send data over the connection by typing into the terminal (which will
not be necessary for this example) and all the data received by `netcat` over
the connection will be printed to the terminal.

While the server is running, in another terminal, run `nc`.

```sh
# Ensure netcat is indeed the program we are using.
$ nc --version
netcat (The GNU Netcat) 0.7.1
Copyright (C) 2002 - 2003  Giovanni Giacobbi

This program comes with NO WARRANTY, to the extent permitted by law.
You may redistribute copies of this program under the terms of
the GNU General Public License.
For more information about these matters, see the file named COPYING.

Original idea and design by Avian Research <hobbit@avian.org>,
Written by Giovanni Giacobbi <giovanni@giacobbi.net>.

# Use netcat to create a connection to our server running on 127.0.0.1
# (localhost) at port 8086.
$ nc 127.0.0.1 8086
2021-08-16 18:27:51 -0400 # this was sent by our server !!
```

If you watch the terminal where the server is running, you should see the
program print `Connection accepted from ...` every time you use `nc`.

`netcat` will execute automatically after the connection is closed by server.
To stop the server itself, use `Control+C` in the server terminal. Some
output like `Traceback ...` may be printed; that can be ignored for now.

### CODE

```rb
require socket
```

Ruby has a standard library module called `socket` (see [relevant
documentation][1]) which contains abstractions for creating and managing
TCP servers and connections. `require` makes those constructs available to
our program below.

```rb
itime = Time.now
print "Initialization time is ", itime, "\n"
```

[`Time`][2] is a class defined in the core libraries. Core libraries are
exactly like the standard library, except it is included by default in the
runtime and we do not need to `require` a package to use `Time`.

The `Time` class has a _static method_ `now` (_static methods_ are also called
_class methods_ and are sometimes identified by the `::` prefix in the
"Methods" section of class documentation). `Time.now` returns the current
system time on the host (including the configured timezone) as an _instance_
or _object_ of `Time` class. We get the current time, and store it in a
variable, as well as print a message containing the _string representation_
of the `Time` object.

The `print` function automatically converts `itime` to the aforementioned
string representation.

```rb
server = TCPServer.new 8086
```

[`TCPServer`][3] is a class from the `socket` module. The static method
`TCPServer.new` constructs a new object of the `TCPServer` class. The method,
like regular functions, requires some arguments. _At least_ a port is
required, which the TCP server will listen on. When a new connection arrives
at the specified port, we can accept the connection and establish a line
of communication with whatever client is trying to connect at that port.

A port is a unique number that your Operating System used to differentiate
between multiple applications listening for packets on the same interface.
It can be any (unique from other applications) 16-bit unsigned integer (so
from 0 to 65535). However, the internet community at large has come to an
agreement about some specific port numbers having special meaning, or to only
be used by specific network services or protocols (see [reference list][4]).

10-bit ports (0 to 1023) are privileged. That means if you write an application
that listens on (for example) port 64, that application requires elevated OS
privileges (super-user on UNIXes and "Run as Administrator" on NT etc.) to
execute.

We have (arbitrarily) picked the port **8086**, however you can pick _any_ port
after and including 1024 (or even a privileged port, just used `sudo` or some
other privilege escalator to run your program – ill-advised, but completely
possible).

At this line, our server has reserved some networking resources, and has
started listening for connections arriving on that port.

```rb
loop do
  # ...
end
```

This is just an _infinite loop_. We want to execute the code between `loop do`
and `end` forever (or until an external event interrupts execution of the
program).

Inside the loop, we collect 3 values.

```rb
conn = server.accept
```
(Indent elided)

Calls the `accept` method on the instance of `TCPServer` that we created
above. This method is _[blocking](#consideration-blocking--concurrency)_,
which means this method "holds" the execution at the current line-of-code,
until a connection arrives on the port that our `server` object is listening
on. Once a connection arrives, it returns the connection object (which we
store in the `conn` variable). Only then does our execution move to the next
line.

```rb
addr = conn.peeraddr[3]
```

(Indent elided)

Once we have the connection object available, we can obtain the address of
_the other computer_ that started the connection. [`conn.peeraddr`][5] is an
array of exactly 4 values. We are only interested in the last of these values,
which would be the IP address (v4 or v6, depending on your networking setup)
of the client.

```rb
time = Time.now
```

(Indent elided)

And here we get the current time, once again.

Note that `time` is different from `itime` not just in variable name, but
in purpose. `itime` was fetched once, at the start of the program. But `time`
is calculate each time a new connection is received. `itime` represents the
time when the program was started (just before `server` started listening)
whereas `itime` represents the time when a client connected to our server
(just after _this_ connection was accepted).

```rb
print "Connection accepted from ", addr, " at ", time, "\n"
```

(Indent elided)

And here we print some of the information we have at this point.

Because ... Why not?

```rb
conn.puts time
```

(Indent elided)

Presuming we still have our connection (i.e. the client has not closed the
connection between now and the time when it was accepted), we write `time`
(again, not `itime`, that is not specific to _this_ connection) to the
connection (`print` again performs the conversion from `Time`
object to a string).

And finally:

```rb
conn.close
```

(Indent elided)

We close our connection. This ensures that regardless of if the client chooses
to disconnect, we force a disconnection after our purpose (sending the current
time) has been fulfilled. This frees up network resources.

We also reached the end of the loop, which means that the execution continues
from the beginning of our (infinite) loop. `server` is now ready to accept a
new connection.

```rb
server.close
```

Once we're done accepting connections, we simply shut down the server.

However, execution never reaches this point, because the infinite loop never
exits. We can quit the program by sending an external interrupt, but that will
stop the execution in its tracks. `server.close` is never executed!

### CONSIDERATION: Blocking & Concurrency

Note that the execution time between we accept a new connection, and when we
close it, is very small. It takes a fraction of a second for our program to
fetch the time, print a few things, send the time to the client and close the
connection.

However, if another connection arrived while this connection was being
"handled", our server would not be able to accept it. A connection is only
accepted while execution is blocked by the `server.accept` method.

This is not such a big problem in our simple time-telling server, but consider
that if processing a connection were to take longer, our server would be
unavailable to other potential clients while one connection is being processed.

In order to accept new connections, we need to implement some form of
_concurrency_ in our program. Concurrency, in simplest terms, means doing
multiple things at once. It would enable us to accept a new connection,
while the previous one is still being processed.

In other words, our server can serve only one client at a time. So it's not
really a good TCP server.

However, as far as any "First TCP Server" goes, this will do. This will do
nicely, indeed.

### CONSIDERATION: Netcat

`netcat` came about in 1995, and quickly became a standard utility on UNIX-like
Operating Systems. Several implementations have been written since. The example
uses [GNU Netcat][8] for no particular reason. Although [OpenBSD Netcat][9]
is also widely available on most UNIXes.

On Microsoft Windows, you could install a Linux/UNIX-compatibility layer like
[Cygwin][10] (and then use the package manager to install `netcat` or
`bsd-netcat` etc.), or [WSL][11], or even find an alternative, of which there
are many.

Whichever tool you use, be sure to read its documentation. For example, here
is the [manual for GNU Netcat][12], which can also be accessed by simply
typing:

```sh
$ man nc
```

on a Linux command-line.

### EXERCISE

- Instead of accepting all connections infinitely, make the server accept at
  most 5 connections. Hint: look for different types of loops in Ruby.
- After a connection is closed, our program immediately loops back and starts
  trying to accept another connection. Make the time before the connection is
  closed longer. Hint: see the `sleep` function.
- Note if the server hangs before closing the connection.
- Observe the client (`nc`) while the server sleeps without closing the
  connection. Report findings.
- Try to start another client while the previous client is still waiting for
  the connection to close. Report findings.

An exercise can be skipped if it takes too long or the objective is unclear.

### ENCLOSED

- [tcp01.rb](../tcp01.rb)

### CHANGELOG

- [2021-08-16] First iteration.

[1]: https://ruby-doc.org/stdlib-3.0.2/libdoc/socket/rdoc/index.html
[2]: https://ruby-doc.org/core-3.0.2/Time.html
[3]: https://ruby-doc.org/stdlib-3.0.2/libdoc/socket/rdoc/TCPServer.html
[4]: https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
[5]: https://ruby-doc.org/stdlib-3.0.1/libdoc/socket/rdoc/IPSocket.html#method-i-peeraddr
[6]: https://en.wikipedia.org/wiki/Network_Time_Protocol
[7]: https://en.wikipedia.org/wiki/Netcat
[8]: http://netcat.sourceforge.net/
[9]: https://sourceforge.net/projects/openbsd-netcat/
[10]: https://www.cygwin.com/
[11]: https://docs.microsoft.com/en-us/windows/wsl/install-win10
[12]: https://man.archlinux.org/man/netcat.1.en
[13]: https://ruby-doc.org/core-3.0.2/Kernel.html#method-i-sleep

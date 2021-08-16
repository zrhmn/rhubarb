# Network Protocols

A network is, in simplest terms, two or more computers exchanging data over
a medium (e.g. a copper cable, radio waves etc.)

For one computer to be able to understand, authenticate, process and
(optionally) respond to data sent by another computer, two conditions must be
met:

1. The computer sending the data must include some information about _what
   it is sending_ along with the raw data. It must also structure the data
   and relevant information in a predefined and consistent manner.
2. The computer receiving data must be able to parse/de-structure the data
   and the relevant information.

In fact, the core requirement is that the way in which data and information
is encapsulated should be _well defined_ and _computationally feasible_. In
order to facilitate this requirement, we have specifications on how certain
types of communication between computers should be carried out. These specs
are called **[Network Protocols][1]**.

Because the nature of communication between two machines can change from one
scenario to another, these Network Protocols come in all shapes and sizes.
The **[OSI Model][2]** of networking layers partially explains the hierarchy
of these protocols.

For example, the protocols defined for the _Physical Layer_ are concerned with
reading bits and bytes from the electrical, electromagnetic (wireless) or
photoelectric (optical fibre) connections. These protocols are usually
implemented directly in the hardware that most computers use for networking,
e.g. Network Interface Cards, WiFi chips etc.

Protocols defined for subsequent layers (2-6) are concerned with different
aspects of communication with those raw bytes grouped into units of data
(packets, frames etc.) This process involves (among other things) ensuring:

- _integrity of data_, meaning data did not get lost or corrupted
  during physical transmission and reception _and_
- _delivery of data to intended recipient_, meaning data sent to `Computer A`
  arrives exactly there in a reasonable amount of time, if Computer A exists
  on the network and a "path" to it can be traced.

**TCP** ([Transmission Control Protocol][3]) falls in that category. To put
it simply, TCP is a set of regulations to ensure two computers can over-time
(continuously, if needed) share data _reliably_. TCP is responsible for
establishing a link to another computer, i.e. `Computer A` knows `Computer B`
is sending some data, it receives and parses packets from the hardware,
extracts the actual data from those packets, performs error-checking and
error-correction etc. and then delivers that data to an application running
on Computer A. As can be imagines, this means `Computer B` must notify
`Computer A` about its intent to send data, and `Computer A` must then
_listen_ for packets arriving from `Computer B`.

**IP** ([Internet Protocol][4]) is closely associated with TCP. IP dictates
how `Computer A` knows about `Computer B` and vice versa. Each computer on
a network is assigned a unique address (IP address) and upon request, a
_path_ can be traced from `Computer A` to `Computer B` (sometimes through
other computers or network devices such as routers, switches etc.) In fact,
if the software responsible for tracing that path is unable to do so, you may
be able to observe errors like `destination host unreachable` etc.

**ICMP** ([Internet Control Messaging Protocol][5]) defines how computers and
network devices can send signals to each other letting them know of their
existence and how they can be reached. `ping` is a well-known program which
builds and sends ICMP packets to other computers, usually to check if they
can be reached.

Many of these protocols are actually implemented in Operating Systems. Any
computer running a modern Operating System already has programs and libraries
that know these protocols, meaning a programmer does not have to write the
business logic for TCP/IP themselves. Instead, they would use the constructs
provided by the OS, e.g. sockets, ports etc. to write their applications.

**HTTP** ([HyperText Transfer Protocol][6]) is an _Application Layer_ protocol.
That means, the business logic for HTTP is usually built into the user-level
application. A programmer creates a TCP connection using the system libraries,
so they do not need to worry about the mechanism by which data reaches the
computer. Instead, they are concerned with the format, presentation and
processing of this data for application-specific purposes.

For example, the business need is for one computer to be able to tell the
time. Using the `Computer A` ⇄ `Computer B` terminology:

- `Computer A`, called _the Server_ should listen for _any_ computer on a
  given network trying to communicate with it.
- `Computer B`, called _the Client_ should set up a connection with the
  aforementioned _Server_ and ask for the time.
- `Computer A` should accept the connection, _read_ the request from the
  aforementioned _Client_.
- `Computer A` should then send the current time, in a pre-defined format
  to the _Client_.
- Both `Computer A` and `Computer B` should then agree that their business has
  concluded, and close the connection (to free network resources)

A whole lot would go into making this happen. Fortunately, most of the
complicated stuff is already taken care of by the Operating System. The
programmer just needs to invoke the right libraries and procedures to let the
OS know that we wish to establish a TCP connection to/from another computer.

Because TCP is a standard protocol, the OS on _Server_ and _Client_ could be
different, but the TCP implementation would work in a (nearly) identical
fashion. That is the advantage of having standardized Network Protocols.

Additionally, higher-level programming languages like Ruby come with standard
libraries that make this process even simpler. Examples from the next few
articles will show how we can completely ignore layers 1-6 of the OSI model
and focus directly on the 7th: _Application Layer_ when writing programs
for networking applications.

### FURTHER READING

- [Understanding TCP/IP: Cisco E-Learning][7]
- [List of OSI Protocols (Layer 1-6): Wikipedia][8]
- [List of Application-specific Protocols: Wikipedia][9]
- [Fundamentals of TCP/IP: Pearson IT Certification][10]
- [A Cake Diagram of TCP/IP Protocols: Programming for Dummies][11]
- [Basics of HTTP: Mozilla Web Docs][12]

### CHANGELOG

- [2021-08-16] First iteration.

[1]:  https://en.wikipedia.org/wiki/Communication_protocol
[2]:  https://en.wikipedia.org/wiki/OSI_model
[3]:  https://en.wikipedia.org/wiki/Transmission_Control_Protocol
[4]:  https://en.wikipedia.org/wiki/Internet_Protocol
[5]:  https://en.wikipedia.org/wiki/Internet_Control_Message_Protocol
[6]:  https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol
[7]:  https://www.cisco.com/E-Learning/bulk/public/tac/cim/cib/using_cisco_ios_software/linked/tcpip.htm
[8]:  https://en.wikipedia.org/wiki/OSI_protocols
[9]:  https://en.wikipedia.org/wiki/Lists_of_network_protocols
[10]: https://www.pearsonitcertification.com/articles/article.aspx?p=1829351
[11]: https://www.dummies.com/programming/networking/network-basics-tcpip-protocol-suite/
[12]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP

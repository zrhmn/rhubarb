# Syntax Spice

See **[ENCLOSED](#enclosed)** at the bottom.

The program we are writing achieves the same business goal as our [First TCP
Server](../tcp01.rb). The differences are in different syntax elements that
[this program](../tcp02.rb) employs.

Unlike _some_ other programming languages, Ruby has a rich syntax; meaning
there exist a lot of syntactic elements that behave differently under
different contexts. It also means there are often multiple ways of expressing
the same solution for a given problem. However, there exist _preferred ways_
of writing solutions to commonly known problems. These preferences tends to
revolve around the basic principles of simplicity, conciseness, readability
and sometimes performance.

When writing code, we consider the best way to write a program that balances
these principles against business requirements. The definition of "best" is
loose and contentious. What may appear to be a good way to express a solution
to one programmer, may not appeal to other programmers with different
experience. Therefore, we endeavor to keep these principles at focus, instead
of specific elements of Ruby syntax.

With Ruby, as with most other programming languages, it is always useful to
look at more than one solutions to the same problem. It lends perspective and
allows opportunities to learn new ways of writing better code.

### EXECUTION

To run the server:

```sh
$ ruby ./tcp01.rb
```

Also [consider shebangs](#consideration-shebangs) if in a UNIX-compatible
environment.

To connect to the server with `netcat`:

```sh
$ nc 127.0.0.1 8086
2021-08-16T23:25:39z
```

### CODE

```rb
puts "Initialization time is #{Time.now()}"
```

Right at the beginning, there are three notable differences in this line.

**1. Use of the [`puts`][2] method instead of [`print`][3]:**

`puts` and `print` perform the same job: printing some value(s) to the
standard output. The difference is, `puts` automatically inserts new-lines
after _each_ of its arguments, while `print` does no such thing. See
[consideration](#consideration-puts-vs-print).

In our use-case, we have just one argument, a single string, to pass to the
`puts` method, and we do not need to manually add a new-line after the
string because `puts` does that anyway.

**2. [String interpolation][4]:**

Before, we were calling the `Time.now` method, storing its returned object in
a separate variable and using `print` to print that variable, along with the
rest of the output string.

Now, instead of that, we invoke the `Time.now` method directly in the string
literal. Ruby will execute any statement found inside `#{...}`, convert its
result to a string, and place that inside the string where `#{...}` was found.

This feature exists in other programming languages, too, and is called
**string interpolation**. Note that this only works inside double-quoted
strings.

**3. Using parentheses `(...)` in method invocation:**

In Ruby, the parentheses in a function or method call are _optional_.
`Time.now` means the same thing as `Time.now()`. Similarly, `puts` can be
called like `puts arg1, arg2, etc` or `puts(arg1, arg2, etc)`. Basically
any function can be called with or without the parentheses.

Consider [the implications](#consideration-parentheses-in-method-calls) of
including or omitting parentheses in function calls.

```rb
TCPServer.open(8086) do |server|
  # ...
end
```

Another common Ruby syntax element is [blocks](#consideration-blocks). They
exist in other languages as well, and are sometimes referred to as _closures_
or _anonymous functions_. Ruby blocks are, however, slightly different from
closures in other languages like JavaScript.

Blocks are groups of statements enclosed between `do ... end` or `{ ... }`.
They also take arguments just like functions, and those arguments are
specified between `|...|` at the start of the block.

Instead of [`TCPServer.new`][6], we now use `TCPServer.open` method to
create our `TCPServer` object. Note that the method `open` isn't defined
directly on `TCPServer`, but is [inherited from the `IO` class][7]. See the
[`TCPServer` inheritance diagram](#consideration-tcpserver-inheritance) for
more details.

The `open` method works differently depending on the context. If followed
immediately by the block, the created instance of `TCPServer` is passed to
the block, and the statements in the block are executed. Furthermore, after
the block exits, the `close` method is automatically called on the `TCPServer`
instance, so we do not have to do that manually.

Inside the block, we can refer to the passed instance as `server`, since
that is the argument name we declared between `|...|` at the start of the
block.

If no block is placed after `TCPServer.open`, it returns the `TCPServer`
instance just like `TCPServer.new`. So the two statements below:

```rb
server = TCPServer.new "127.0.0.1" 8086

# and

server = TCPServer.open "127.0.0.1" 8086
```

are equivalent to each other, in the absence of a block following
`TCPServer.open`.

Inside the block:

```rb
while conn = server.accept()
  # ...
  conn.puts time.gmtime().strftime('%FT%Tz')
  # ...
end
```

(Indent elided)

Before, we had an infinite loop, and in the first statement inside the loop
we were calling `server.accept`, which blocks until a new connection arrives,
then returns the connection instance, which we stored in a variable.

Here we moved all of that logic into a [`while`][10] loop.

At each iteration of the loop, `server.accept` is called, which, as usual
blocks until it has a connection available to return. Once a connection
arrives, it returns the value which is put in the `conn` variable.

However, `while` loop is conditional. If for some reason `server.accept`
fails, it returns a `nil` object. Being equivalent to `false`, the `while`
loop immediately terminates if `server.accept` ever returns `nil`. But that
can only happen in the rarest of corner cases, so _in practice_ our `while`
loop ends up being equivalent to the infinite loop we had before.

The only benefit we get from using `while` instead of an infinite loop is
readability. Our business logic is slightly more compact, since we moved the
`conn = server.accept` line in the loop condition. Furthermore, infinite loops
are hard to debug and it is advisable to avoid infinite loop and always make
your loops conditional, to the extent of possibility.

It is, however, a different syntactic element to learn, recognize and apply
in situations where there is a demand for it.

In the statement:

```rb
conn.puts time.gmtime().strftime('%FT%Tz')
```

(Indent elided)

There is another example of [method chaining][5].

`time` is an object, or instance of the [`Time`][11] class. We call the
[`gmtime`][12] method on it, which converts the time to **GMT** or **UTC**
timezone. It also returns a (different) `Time` instance.

And in the same statement, we call the [`strftime`][13] method on the object
returned by the `gmtime` method. `strftime` take a format string and returns
the string representation of the `Time` object, according to the given
format string. See the documentation for [`strftime`][13] to find out more
about what format flags do what.

### CONSIDERATION: Shebangs

You can invoke a (compiled) binary executable by simply giving its relative
path to a POSIX-compatible shell. For example, to run a program called `prog`
in the current directory, you can simply do:

```sh
$ ./prog
[OUTPUT ...]
```

Because the program is compiled machine code, the Operating System loads it
into memory and executes it in the normal way.

However, programs written in interpreted languages like Python, Ruby, Perl
etc. appear as plain text files to the Operating System. Since it is not
a binary executable, the OS does not _how_ to execute the file. However, in
POSIX-compatible shells, we have a way of telling the Operating System to
pass the text in the program to an interpreter.

We can just include a line at the top of our program, starting with `#!`
followed by a path to the executable interpreter, along with any command-line
parameters for the interpreter, if necessary. This line is called a
[shebang][1].

For example, consider the following Ruby program called `prog.rb`.

```rb
#!/usr/local/bin/ruby -w

puts "Hello, world!"
```

We _must_ give this file executable permissions as well.

```sh
$ chmod +x ./prog.rb
```

After that, when the program is invoked like so:

```sh
$ ./prog.rb
```

the Operating System reads the first line, runs the Ruby interpreter (which
exists at the path specified in the shebang line), and passes the rest of the
program to it. Ergo, this entire process is equivalent to simply executing:

```sh
$ /usr/bin/ruby -w ./prog.rb
```

The `-w` is just an option passed to the interpreter, telling it to turn on
warnings during the execution of our program.

In order to run [`tcp02.rb`](../tcp02.rb) with a shebang, follow these
instructions.

```sh
# Make a copy of the file. The .rb extension is not necessary.
$ cp tcp02.rb tcp02

# Find out where the ruby interpreter is located on your computer.
# Most installers and package managers will store it at a standard location.
$ which ruby
/usr/local/bin/ruby

# Edit the copy (tcp02) and insert the shebang line at the top.
# The shebang line must have a location of the interpreter as printed by the
# preceding `which` command. It should look like this:
#!/usr/local/bin/ruby

# You may choose to include `-w` at the end of the shebang.

# Give the edited copy (tcp02) executable permission.
$ chmod +x tcp02

# Execute it just like a binary
$ ./tcp02
```

Being familiar with shebangs will come in handy when writing scripts or small
utility programs.

### CONSIDERATION: `puts` vs `print`

As described before, `puts` adds a new-line character after each of its
arguments, including the last one. So something like:

```rb
puts(0, "", 1)
```

will result in 3 lines being printed, with each of its arguments on a separate
line. Since the middle argument is an empty string, it appears as an empty
line in the output.

```sh
# OUTPUT
0

1
```

However, `print` simply prints all of its arguments to the standard output
with no automatic whitespace insertion. e.g.

```rb
print(0, "", 1)
print("Hello, world!\n")
```

yields the following output:

```sh
# OUTPUT
01Hello, world!
```

Note that `print` did not add a new-line even after the last argument (the
digit `1`) and the subsequent `print` started at the same line, right after
the last character printed.

When using `print` we have to manually manage whitespace. In some cases, we
do not need automatic new-lines, and want to choose how the output will be
arranged into lines. That is when `print` is useful instead of `puts`.

### CONSIDERATION: Parentheses in Method Calls

As mentioned before, parentheses can be omitted when calling a method or a
function. But that is not always advisable.

Consider the following statement:

```rb
obj.method(arg).another_method another_arg
```

The statement calls `method` of `obj`. Some value is returned, perhaps another
object. Then `another_method` of the returned object is called in the same
statement. This is called [method chaining][5].

The single statement is equivalent to the combination of following two
statements.

```rb
another_obj = obj.method arg
another_obj.another_method another_arg
```

Note the placement of parentheses in the first, method-chained statement.
If it was written like:

```rb
obj.method arg .another_method another_arg
```

The intent is ambiguous. Is `.another_method` being called on the return value
from `method` or on the `arg` which is passed to `method`?

There will always be situations where parentheses are required to make the
statement less ambiguous and/or syntactically valid. In the interest of
maintaining a uniform code-style, one may consider _always_ including
parentheses, even when they can be omitted.

### CONSIDERATION: Blocks

Blocks are like in-place functions. Arguments are placed between `|...|`,
followed immediately by the _body_ of the function, or in other words, one
or more statements that would be executed with the supplied arguments.

Methods that make use of blocks must do so with the `yield` keyword.

For example:

```rb
def method (arg)
  puts "inside method, arg is #{arg}",
       "yielding to block"

  yield arg + 1

  puts "block execution finished, back inside method",
       "fin"
end

method(22) do |num|
  puts "inside block, num is #{num}"
end
```

The output of the above piece of code is:

```
inside method, arg is 22
yielding to block
inside block, num is 23
block execution finished, back inside method
fin
```

So what happens here?

A method named `method` is defined, which accepts one argument named `arg`.
When this method is called: `method(22)`, the first statement inside method:
`puts ...` executes, printing the value of `arg` as was supplied in the
method call.

Then the `yield` keyword causes the block to execute. The `puts ...` inside
the block prints the value of _its own_ argument named `num`. Note that
`yield` explicitly passed `arg + 1` to the block, so that is what got
printed.

Once the block terminates, execution resumes inside the `method` immediately
after `yield` and the rest of the method is executed.

Taking the example of `TCPServer.open` method, we can picture that the `open`
method is defined _something like_ this:

```rb
def open(port)
  serv = ... # somehow create an instance of TCPServer

  yield serv # pass the instance to block

  serv.close # clean up OS resources etc.
end
```

Which is not very accurate, because the actual `open` method is defined
differently. However, the effect is the same.

It therefore causes our code:

```rb
TCPServer.open(8086) do |server|
  # ...

  while conn = server.accept
    # ...
  end
end
```

to work as expected. At `yield` the `TCPServer` instance is handed to our
block, where we call `accept` on it to wait for and process incoming
connection.

### CONSIDERATION: `TCPServer` Inheritance

```
                          ┌───────────────────┐
                          │                   │
                          │        IO         │
                          │                   │
                          └─────────┬─────────┘
                                    │
                                    │
                          ┌─────────▼─────────┐
                          │                   │
                          │    BasicSocket    │
                          │                   │
                          └─────────┬─────────┘
                                    │
          ┌─────────────────────────┼─────────────────────────┐
          │                         │                         │
┌─────────▼─────────┐     ┌─────────▼─────────┐     ┌─────────▼─────────┐
│                   │     │                   │     │                   │
│     UNIXSocket    │     │     IPSocket      │     │       Socket      │
│                   │     │                   │     │                   │
└───────────────────┘     └─────────┬─────────┘     └───────────────────┘
                                    │
                       ┌────────────┴─────────────┐
                       │                          │
             ┌─────────▼─────────┐      ┌─────────▼─────────┐
             │                   │      │                   │
             │     UDPSocket     │      │     TCPSocket     │
             │                   │      │                   │
             └───────────────────┘      └─────────┬─────────┘
                                                  │
                                                  │
                                        ┌─────────▼─────────┐
                                        │                   │
                                        │     TCPServer     │
                                        │                   │
                                        └───────────────────┘
```

Search [RubyDocs][8] for relevant documentation on mentioned classes.

The [`IO`][9] class defines a common structure for all input/output operations
performed by the Operating System. This includes devices, files, processes
and indeed, sockets. Recall the various protocols mentioned in the
[Network Protocols](./NETWORK_PROTOCOLS.md) article. The classes in the
diagram each wraps the OS-level constructs for handling various underlying
network protocols.

### EXERCISE

- Analyze [line #6](../tcp02.rb#L6) of the example, specifically the
  `addr[1]` part. Answer the following question:
  - How many elements are in the `server.addr` array?
  - What is the significance of element #1?
  - Include both element #2 and element #1 in the string that is printed.
- Use `strftime` to send time in a format other than the one used in the
  example.
- Write your own TCPServer which sends a greeting, like `"Hello, visitor!"`
  before sending the time. Make sure the greeting is printed on a different
  line.
- Parentheses are missing from some method calls, while included in others.
  - Add parentheses where they are missing.
  - Is there a place where omitting parentheses causes ambiguity?
  - If so, report findings and ensure parentheses are included to remove
    syntactical ambiguity.
- What is the super-class of `TCPServer`? Consult the [inheritance
  diagram](#consideration-tcpserver-inheritance) to answer this question.

### ENCLOSED

- [tcp02.rb](../tcp02.rb)

### CHANGELOG

- [2021-08-16] First iteration (incomplete).
- [2021-08-18] Add CODE and CONSIDERATION sections.


[1]: https://en.wikipedia.org/wiki/Shebang_(Unix)
[2]: https://ruby-doc.org/core-2.6/IO.html#method-i-puts
[3]: https://ruby-doc.org/core-2.6/IO.html#method-i-print
[4]: https://docs.ruby-lang.org/en/2.0.0/syntax/literals_rdoc.html#label-Strings
[5]: https://en.wikipedia.org/wiki/Method_chaining
[6]: https://ruby-doc.org/stdlib-3.0.2/libdoc/socket/rdoc/TCPServer.html
[7]: https://ruby-doc.org/core-3.0.2/IO.html#method-c-open
[8]: https://docs.ruby-lang.org/en/2.6.0/
[9]: https://docs.ruby-lang.org/en/2.6.0/IO.html
[10]: https://ruby-doc.org/core-2.6/doc/syntax/control_expressions_rdoc.html#label-while+Loop
[11]: https://ruby-doc.org/core-2.6/Time.html
[12]: https://ruby-doc.org/core-2.6/Time.html#method-i-gmtime
[13]: https://ruby-doc.org/core-2.6/Time.html#method-i-strftime

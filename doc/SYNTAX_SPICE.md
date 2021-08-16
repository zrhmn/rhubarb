# Syntax Spice

See **[ENCLOSED](#enclosed)** at the bottom.

We improve upon the previous example, looking at different elements of Ruby
syntax and when a particular way of doing something may be preferable to
another.

### EXECUTION

To run the server:

```sh
$ ruby ./tcp01.rb
```

Alternatively, if you are on a UNIX-like system which supports shebangs, you
can add the following line at the top of the program:

```rb
#!/usr/local/bin/ruby
```

Then you can assign the file "executable" permissions by:

```sh
$ chmod +x ./tcp01.rb
```

And execute the program like you would execute a binary-executable file:

```sh
$ ./tcp02.rb
```

For more details, look up "unix shebang".  
[ TODO: Links to relevant documentation and **CONSIDERATION: Shebang** ]

To connect to the server with `netcat`:

```sh
$ nc 127.0.0.1 8086
2021-08-16T23:25:39z
```

### [ TODO: CODE/CONSIDERATION/EXERCISE ]

### ENCLOSED

- [tcp02.rb](../tcp02.rb)

### CHANGELOG

- [2021-08-16] First iteration (incomplete).

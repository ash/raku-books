---
title: 95. The cat utility
---

{% include menu.html %}

*Create the equivalent of the UNIX cat utility that copies its STDIN input directly to STDOUT.*

Reading from the input and sending it to the output is a relatively easy task. The `$*IN` handle is by default connected to STDIN. Being an object of the `IO::Handle` type, it has the `slurp` method that returns the whole input text in one go. What is left to do, is just to print it to the output, which defaults to STDOUT.

Here’s the complete program:

```raku-local
say $*IN.slurp;
```

This works well, and we can use it via the command line:

```
$ raku cat.rk < file1.txt > file2.txt
```

However, in the interactive mode, the program does not replicate each entered line, but instead, it waits until the end of the output (say, until you press Ctrl+D). This behaviour is fully explainable because of the use of the `slurp` method.

Let us modify the program so that it prints each line as soon as it is entered. The `IO::Handle` class has another method, `get`, which reads one line from the handle and returns it. Create a loop and print the line after it is delivered by the `get` method:

```raku-static
.say while $_ = $*IN.get;
```

Here, the default variable `$_` is used. This allows to omit creating the new variable and to make the whole program more compact. The `.say` call in it is a shortcut for `$_.say`.

{% include nav.html %}

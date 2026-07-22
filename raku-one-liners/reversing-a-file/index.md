---
title: Reversing a file
---

{% include menu.html %}

In this section, we are creating a one-liner to print the lines of a text file in reversed order (as `tail -r` does it).

The first one-liner does the job with the STDIN stream:

```raku-static
.say for $*IN.lines.reverse
```

Run the program as:

```
$ raku reverse.raku < text.txt
```

`$*IN` can be omitted in this case, which makes the one-liner even shorter:

```raku-static
.say for lines.reverse
```

If you want to read the files directly from Raku, modify the program a bit to create a file handle out of the command-line argument:

```raku-local
.say for @*ARGS[0].IO.open.lines.reverse
```

Now you run it as follows:

```
$ raku reverse.raku text.txt
```

It is important to remember that the default behaviour of the `lines` method is to exclude the newline characters from the final sequence of lines (the method returns a `Seq` object, not an array or a list).

In Raku, the `lines` method splits the lines based on the value stored in the `.nl-in` attribute of the `IO::Handle` object.

You can look at the current value of the line separators with the following tiny script:

```raku-local
dd $_ for @*ARGS[0].IO.open.nl-in
```

This is what you find there by default:

```raku-static
$["\n", "\r\n"]
```

The interesting thing is that you can control the behaviour of `lines` and tell Raku not to exclude the newline characters:

```raku-local
@*ARGS[0].IO.open(chomp => False).lines.reverse.put
```

The `chomp` attribute is set to `True` by default. You can also change the default separator:

```raku-local
@*ARGS[0].IO.open(
    nl-in => "\r", chomp => False
).lines.reverse.put
```

Notice that without chomping, you do not need an explicit `for` loop over the lines: in the last two one-liners, the `.put` method is called directly on the sequence object. In the earlier versions, the strings did not contain the newline characters, and thus they would be printed as a single long line.

*A small homework for you: Tell the difference between `put` and `say`.*

{% include nav.html %}

---
title: 74. Skipping Pod documentation
---

{% include menu.html %}

*Create the program that copies the input text and skips the documentation in the Pod style that starts with =begin and ends with =end.*

Let us take a simple text containing a piece of Pod documentation:

```raku-static
# Hello, World!
=begin
This program prints a message
=end
say 'Hello, World!';
```

The program should read it and print everything that is not the comment. Thus, for the given example, only the first and the last lines can go to the output.

There is a family of flipflop operators that, although being a bit hard to understand at first, are quite powerful for introducing the two-state triggers in the program flow.

```raku-static
while $_ = $*IN.get {
    .say unless /^'=begin'/ ff /^'=end'/;
}
```

Reading lines from the STDIN handle is the same as it will be done it in task 95, The cat utility. The flipflop construct `/^'=begin'/ ff /^'=end'/` is `False` initially and becomes `True` as soon as the `$_` content matches the first regex. After that, it stays `True` until the second condition is `True`.

In the end, the `unless` clause only passes the lines that are not located between the `=begin` and `=end` instructions. The `.say` method call is thus printing all the remaining lines.

{% include nav.html %}

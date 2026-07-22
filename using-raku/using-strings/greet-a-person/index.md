---
title: 2. Greet a person
---

{% include menu.html %}

*Ask a user for their name and greet them by printing ‘Hello, <Name>!’*

Raku offers a simple `prompt` function that performs both actions: prints a prompt and reads the input. So, the program using it may look like this:

```raku
say 'Hello, ' ~ prompt('Enter your name: ') ~ '!';
```

The `~` operator stands for string concatenation. Don’t be confused by the sequence of text strings in this code. To build the string, Raku needs to have all its parts. Two of them (`'Hello',` and `'!'`) are presented by literal strings, while the middle part needs user input. Therefore, the flow of the whole program remains logical:

```
Enter your name: Andy
Hello, Andy!
```

If you prefer a more traditional program flow, split it into separate parts and interpolate a variable in a string:

```raku
my $name = prompt('Enter your name: ');
say "Hello, $name!";
```

Alternatively, the `get` function may be used. It returns the input line without the newline character. Printing a prompt message is your responsibility now:

```raku
print 'Enter your name: ';
my $name = get();
say "Hello, $name!";
```

The `get` function may be called as a method on the `$*IN` variable, which is by default connected to the standard input:

```raku-static
my $name = $*IN.get();
```

{% include nav.html %}

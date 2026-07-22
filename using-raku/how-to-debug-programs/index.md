---
title: How to debug programs
---

{% include menu.html %}

For quick tests, use the compiler in the mode of the REPL (read—eval— print loop) shell. Just run the `raku` command1:

```
$ raku
To exit type 'exit' or '^D'
>
```

With bigger programs, one of the following techniques helps to visualise data:

1. The `say` routine is used as a stand-alone function or as an object method. It works well with both scalar and aggregate data, such as arrays, hashes, or objects:

```raku-static
say $x;
%data.say;
```

3. The `WHAT` and the `^name` methods, which give you the information about the object type or class name:

```raku
my Int $x;
say $x.WHAT;  # (Int)
say $x.^name; # Int
```

4. The `dd` routine. This is a Rakudo-specific feature that dumps an object:

```raku-static
my @a = 1..5;
dd @a; # Array @a = [1, 2, 3, 4, 5]
```

1 Before the rename is complete, use the `perl6` command or make an alias.

{% include nav.html %}

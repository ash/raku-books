---
title: Examples of short one-lines
---

{% include menu.html %}

To warm up, let’s start with a few simple one-liners for working with files. (There’s also the whole Chapter 2 which is about working with files).

Double-space a file

```
$ raku -npe's/$/\n/' text.txt
```

Remove all blank lines

```
$ raku -ne'.say if .chars' text.txt
```

Depending on how you define ‘blank’, you may want another one-liner that skips the lines containing whitespaces:

```
$ raku -ne'.say if /\S/' text.txt
```

Number all lines in a file

```
$ raku -ne'say ++$ ~ ". " ~ $_' text.txt
```

This code, probably, requires a comment. The `$` variable is a state variable and it can be used without declaration.

Convert all text to uppercase

```
$ raku -npe'.=uc' text.txt
```

Strip whitespace from the beginning and end of each line

```
$ raku -npe'.=trim' text.txt
```

Print the first line of a file

```
$ raku -ne'.say ; exit' text.txt
```

Print the first 10 lines of a file

```
$ raku -npe'exit if $++ == 10' text.txt
```

This time, the postfix `++` operator was applied to the `$` variable.

{% include nav.html %}

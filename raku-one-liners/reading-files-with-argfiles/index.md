---
title: Reading files with $*ARGFILES
---

{% include menu.html %}

`$*ARGFILES` is a built-in dynamic variable that may be handy when working with multiple input files.

How do you read two or more files passed in the command line?

```
$ raku work.pl a.txt b.txt
```

If you need to process all files together as if they are a single data source, you could ask the variable to do the job in a one-liner:

```raku-static
.say for $*ARGFILES.lines
```

Inside the program, you don’t have to think about looping over the files; `$*ARGFILES` will automatically do that for you.

If there are no files in the command line, the variable will be attached to STDIN:

```
$ cat a.txt b.txt | raku work.pl
```

Handy indeed, isn’t it?

$*ARGFILES and MAIN

I also have to warn you if you will want to use the `$*ARGFILES` variable in bigger programs. Consider the following example:

```raku-static
sub MAIN(*@files) {
    .say for $*ARGFILES.lines;
}
```

In the recent versions of Raku, `$*ARGFILES` works differently inside the `MAIN` subroutine and outside of it.

This program will perfectly work with the earlier versions (before and including Rakudo version 2018.10). Starting from Rakudo Star 2018.12, `$*ARGFILES`, if used inside MAIN, is always connected to `$*IN`.

{% include nav.html %}

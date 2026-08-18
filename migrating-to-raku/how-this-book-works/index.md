---
title: How This Book Works
---

{% include menu.html %}

Every section follows the same rhythm. We start from a piece of Perl that you
could have written yourself, then transform it into Raku one step at a time. The
goal is that by the end of a section you can recognise the pattern instantly and
reach for the Raku form without thinking about it.

## The two languages side by side

Perl examples are shown first:

```perl
use v5.10;
say 'Hello, World!';
```

and the Raku version follows:

```raku
say 'Hello, World!';
```

## File-name conventions

To tell the two apart when we save programs to disk, this book uses the `.pl`
extension for Perl and `.raku` for Raku. Nothing forces this on you — the
Raku specification does not require a particular extension, and you may keep
using `.pl` if you like — but the split keeps the examples unambiguous.

Running a Perl program:

```
$ perl 002-hello-world.pl
```

Running a Raku program:

```
$ raku 002-hello-world.raku
```

Or, with the Raku++ compiler introduced in the preface:

```
$ rakupp 002-hello-world.raku
```

## What you need installed

Both compilers, side by side: a Perl no older than 5.12, and a recent Rakudo.
When we activate a Perl feature such as `say`, we assume `use v5.10;` at the
top of every Perl program that needs it, even where it is omitted for brevity.
Raku++ (`rakupp`) is optional — a second Raku implementation you may install
alongside Rakudo if you would like to try it, as described in the preface.

{% include nav.html %}

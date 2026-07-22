---
title: Frequently used special variables
---

{% include menu.html %}

The `$_` variable is the one similar to that in Perl 5, which is the default variable containing the current context argument in some cases. Like any other variable, the `$_` is an object in Perl 6, even in the simplest use cases. For example, the recent example `.say for` `@*ARGS` implicitly contains the `$_.say` call. The same effect would give `$_.say()`, `.say()`, or just `.say`.

This variable is used as a default variable in other cases, for instance, during the match against regular expressions:

```raku-local
for @*ARGS {
    .say if /\d/;
}
```

This short code is equivalent to the following, which uses the smartmatch (`~~`) operator:

```raku-local
for @*ARGS {
    $_.say if $_ ~~ /\d/;
}
```

The result of matching against a regular expression is available in the `$/` variable. To get the matched string, you may call the `$/.Str` method. So as to get the substrings, which were caught during the match, indices are used: `$/[2]` or, in a simpler form, `$2`.

```raku
"Perl’s Birthday: 18 December 1987" ~~ 
    / (\d+) \s (\D+) \s (\d+) /;
say $/.Str;
say $/[$_] for 0..2;
```

Here, we are looking for a date. In this case, the date is defined as a sequence of digits `\d+`, a space `\s`, the word having no digits `\D+`, another space `\s`, and some more digits `\d+`. If the match succeeded, the `$/.Str` slot contains the whole date, while the `$/[0]`, `$/[1]`, and `$/[2]` keep their parts (the small square corner brackets are part of the output to indicate the `Match` object, see Chapter 6):

```
18 December 1987
｢18｣
｢December｣
｢1987｣
```

Finally, the `$!` variable will contain an error message, for example, the one that occurred within a `try` block, or the one that happened while opening a file:

`try {`

`say 42/0;`

`}`

```raku-static
say $! if $!;
```

If you remove the last line in this programme, nothing will be printed. This is because the try block masks any error output. Remove the `try`, and the error message reappears (the programme, itself, is terminated).

{% include nav.html %}

---
title: 12. Plural endings
---

{% include menu.html %}

*Put a noun in the correct form—singular or plural—depending on the number next to it.*

In program outputs, it is often required to print some number followed by a noun, for example:

```
10 files copied
```

If there is only one file, then the phrase should be ‘`1 file copied`’ instead. Let’s see how the language can help.

Of course, it is quite easy to print a noun separately using string concatenation to make the whole phrase:

```raku
for 1, 2, 3 -> $n {                     # Program output:
    my $word = 'file';                  # 1 file found
    $word ~= 's' if $n > 1;             # 2 files found
    say "$n $word found";               # 3 files found
}
```

It is also a good practice to interpolate the word choice into the string itself to avoid additional lines of code and to get rid of temporary variables.

The following program generates the same output:

```raku
for 1, 2, 3 -> $n {
    say "$n file{'s' if $n > 1} found";
}
```

A code block in curly braces inside the string contains a regular Raku code. It returns `'s'` if the number `$n` is greater than one. Notice that there is no need to use a ternary operator here; a postfix `if` looks very self-explaining.

{% include nav.html %}

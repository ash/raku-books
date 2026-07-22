---
title: 6. Removing blanks from a string
---

{% include menu.html %}

*Remove leading, trailing and double spaces from a given string.*

This task often occurs when you need to clean the user input, such as from web forms, where leading or trailing spaces in, for example, names, are most likely user mistakes and should be removed.

Removing double and multiple spaces between words can be solved by using substitution:

```raku-static
my $string = 'Hello,     World!';
$string ~~ s:g/\s+/ /;
```

Don’t forget to make the substitution global with the `:g` adverb to find all the occurrences of repeated spaces.

Leading and trailing spaces can be removed with the `trim` routine:

```raku
my $string = ' Hello, World! ';
say trim($string);
```

The `trim` routine exists as a self-standing function, as shown in the previous example, as well as a method of the `Str` class, so it can be called on a variable or on a string:

```raku-static
say $string.trim;
say ' Hello, World! '.trim;
```

There are also two routines, `trim-leading` and `trim-trailing`, which remove either only leading or only trailing spaces.

```raku
say '¡' ~ '  Hi  '.trim-leading;  # ¡Hi
say '  Hi  '.trim-trailing ~ '!'; #   Hi!
```

{% include nav.html %}

---
title: String operators
---

{% include menu.html %}

`~` does the string concatenation. The dot in Perl 6 is now used for dealing with methods; thus, a new operator for the string concatenation was required. The tilde was a good candidate because it is also used in other string-related operators in Perl 6.

```raku
say "a" ~ "b"; # ab
```

If necessary, the operator converts its operands to the string type.

```raku
say "N" ~ 1; # N1
say 4 ~ 2;   # 42
```

`x` repeats the string the given number of times.

```raku
say "A" x 5; # AAAAA
```

Non-string values will be converted to strings before the operation.

```raku
say 0 x 5; # 00000
```

If the number of repetitions is negative or zero, an empty string is returned.

{% include nav.html %}

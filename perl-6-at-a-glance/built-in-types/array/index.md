---
title: Array
---

{% include menu.html %}

The `Array` variables (i.e., all the variables starting with the `@` sigil) are equipped with a couple of simple but rather useful methods.

```raku
my @a = 1, 2, 3, 5, 7, 11;
say @a.Int; # array length
say @a.Str; # space-separated values
```

If you print an array, you get its value as a space-separated list in square brackets. Alternatively, you may interpolate it in a string.

```raku
my @a = 1, 2, 3, 5, 7, 11;

say @a;                 # [1 2 3 5 7 11]
say "This is @a: @a[]"; # This is @a: 1 2 3 5 7 11
```

{% include nav.html %}

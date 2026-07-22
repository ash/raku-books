---
title: 62. Finding unique elements
---

{% include menu.html %}

*Print all unique elements of the given array.*

Objects of the `Array` type have the `unique` method.

```raku
my @a = 2, 3, 7, 4, 5, 5, 6, 2, 10, 7;
say @a.unique;
```

The result of running this program is a sequence containing the unique elements: `(2 3 7 4 5 6 10)`.

Notice that the values are not sorted and appear in the same order as they first appeared in the original data, which stays unchanged.

The routine can be used as a function:

```raku-static
say unique(@a);
```

It can also take a code block or a reference passed via the `with` named argument to replace the default comparison method. The following example demonstrates how to select rational numbers that only repeat once within the given integer part.

```raku
<1.1 1.3 2.2 2.5 3.6>.unique(with => {
    $^a.Int == $^b.Int;
}).say;
```

From the given list of numbers, only three pass the filter: `(1.1 2.2 3.6)`.

The `$^a` and `$^b` are the placeholder variables that receive pairs of values when the `with` code block is activated. Alternatively, arguments with explicit names may be used:

```raku-static
unique(@data, with => -> $x, $y {$x.Int == $y.Int}).say;
```

{% include nav.html %}

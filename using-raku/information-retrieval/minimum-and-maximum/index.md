---
title: 63. Minimum and maximum
---

{% include menu.html %}

*Find the minimum and the maximum numbers in the given list of integers.*

Finding the minimum and maximum elements of arrays is extremely easy. For iterable objects, the two methods, `min` and `max`, are defined.

```raku
my @list = 7, 6, 12, 3, 4, 10, 2, 5, 15, 6, 7, 8, 9, 3;

say @list.min;
say @list.max;
```

For the list in the example, this program prints two numbers:

The `min` and `max` routines can be used as binary operators, in which case they return the smaller or the bigger number:

```raku
say 7 min 8; # Prints 7
say 7 max 8; # Prints 8
```

Operators can be chained like this:

```raku
say 7 min 5 min 8; # Prints 5
say 7 max 5 max 8; # Prints 8
```

This can be expressed with the help of a reduction meta-operator `[`…`]`:

```raku
say [min] 7, 9, 5; # Prints 5
say [max] 7, 9, 4; # Prints 9
```

Lists are also accepted, for example: `say [min] @list`.

{% include nav.html %}

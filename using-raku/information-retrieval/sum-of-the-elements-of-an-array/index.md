---
title: 55. Sum of the elements of an array
---

{% include menu.html %}

*Find the sum of the elements of an array of integers.*

There is an array of integers:

```raku-static
my @a = (4, 6, 8, 1, 0, 58, 1, 34, 7, 4, 2);
```

There is no need to explicitly iterate over the elements to calculate the sum of its elements. Rather use the reduction operator:

```raku-static
say [+] @a;
```

Any reduction operator takes a list of values and inserts the actual operator between them.

For example, to get the sum of all the elements that are greater than 10, grep the initial array and apply `[+]` to it:

```raku-static
say [+] grep {$_ > 10}, @a; # Prints 92
```

If you prefer more unreadable syntax, the reduction operation can be spelled down wordier:

```raku-static
say reduce &infix:<+>, @a; # Prints 125
```

This gives the same result as say `[+] @a`, which is the better choice in most cases.

Here’s another simple solution using the `sum` method:

```raku
my @a = (4, 6, 8, 1, 0, 58, 1, 34, 7, 4, 2);
say @a.sum(); # Also 125
```

Chose whatever approach you like the most.

{% include nav.html %}

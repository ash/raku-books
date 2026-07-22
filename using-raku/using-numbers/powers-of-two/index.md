---
title: 23. Powers of two
---

{% include menu.html %}

*Print the first ten powers of two.*

The naïve loop for calculating powers of two can be created similar to the solution of the Task 22, Print squares:

```raku
say 2 ** $_ for 0..9;
```

It prints the values 1, 2, 4, etc. up to 512.

There’s another way of generating sequences with the defined rule of calculating its elements:

```raku
my @power2 = 1, 2, {$_ * 2} ... *;
.say for @power2[^10];
```

The rule here is `{$_ * 2}`, so each next number is twice as big as the previous one. The `@power2` array gets the values of the infinite lazy list, and only the first ten elements are used for printing. The `^10` construction at the place of array index creates a range `0..9`, and the corresponding slice of `@power2` is taken.

Raku also can deduce the rule if you provide the first few elements of the list:

```raku
my @power2 = 1, 2, 4 ... *;
.say for @power2[^10];
```

In the less obvious cases, you’d better prefer an explicit generator for lazy lists.

{% include nav.html %}

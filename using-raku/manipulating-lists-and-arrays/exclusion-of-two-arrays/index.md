---
title: 54. Exclusion of two arrays
---

{% include menu.html %}

*From the given two arrays, find the elements of the first array which do not appear in the second one.*

Take two arbitrary arrays of integers:

```raku-static
my @a = 2, 5, 7, 8, 10;
my @b = 1, 3, 5, 7, 9;
```

The program should print 2, 8, and 10. Here is a possible solution:

```raku-static
.say for (@a ∖ @b).keys;
```

Notice that the ∖ infix operator is a Unicode character, not an ASCII backslash. Most likely, it is better to avoid using it in favour of its ASCII replacement:

```raku-static
.say for (@a (-) @b).keys;
```

In these examples, the arrays are converted to sets before the operation.

Sets do not keep the order, thus if you need to preserve the order, you can do it differently:

```raku-static
.say for grep *  @b, @a;
```

The `grep` function gets a `WhateverCode` block `*` `$b`, which is equivalent to the block with the default variable: `{$_` `$b}`.

The operator returns `True` if its first operand, being treated as a set, is contained within the set on the right-hand side. The operator can be spelled purely in ASCII:

```raku-static
.say for grep * !(<) $b, @a;
```

{% include nav.html %}

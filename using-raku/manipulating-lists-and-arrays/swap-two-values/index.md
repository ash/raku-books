---
title: 48. Swap two values
---

{% include menu.html %}

*Swap the values of two variables.*

In Raku, there is no need to use temporary variables to swap the values of two variables. Just use the lists on both sides of the equation:

```raku-static
($b, $a) = ($a, $b);
```

Alternatively, call the `reverse` method and assign the result back to the values:

```raku-static
($a, $b).=reverse;
```

Consider the complete program:

```raku
my ($a, $b) = (10, 20);
($b, $a) = ($a, $b);
say "\$a = $a, \$b = $b";
```

This program prints the swapped values:

```raku-static
$a = 20, $b = 10
```

This approach also works with elements of an array:

```raku
my @a = (3, 5, 7, 4);
(@a[2], @a[3]) = (@a[3], @a[2]);
say @a; # [3 5 4 7]
```

A slice of an array may be used instead of an explicit list:

```raku
my @a = (3, 5, 7, 4);
@a[1, 2] = @a[2, 1];
say @a; # [3 7 5 4]
```

{% include nav.html %}

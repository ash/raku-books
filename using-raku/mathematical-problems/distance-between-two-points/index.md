---
title: 35. Distance between two points
---

{% include menu.html %}

*Calculate the distance between the two points on a surface.*

There are two points on a surface, each with their own coordinates, x and y. The task is to find the distance between these two points.

A straightforward solution would be to use the Pythagorean theorem:

```raku
my ($x1, $y1) = (10, 3);
my ($x2, $y2) = (9, 1);
say sqrt(($x1 - $x2) ** 2 + ($y1 - $y2) ** 2);
```

This works, but it requires a lot of typing. In Raku, there is a slightly easier way if you use complex numbers.

```raku
my $a = 10+3i;
my $b = 9+1i;
say ($a - $b).abs;
```

The result of both programs is the same. Complex numbers are objects of the `Complex` data type and are introduced via i—the imaginary unit:

The result of the difference `$a - $b` is also a complex number, and the `abs` method can be called on it. This method returns the absolute value of a complex number, which is actually the distance between the two points.

Notice the style: `10+3i` vs. `10 + 3i`. The first one seems to be preferable as it is also used as the default output format by the compiler. The second option may be confusing when a complex number is used in an expression with other variables or numbers.

```
$ raku -e'say (10+3i, -i, 4i, 10+0i)'
(10+3i -0-1i 0+4i 10+0i)
```

{% include nav.html %}

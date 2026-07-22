---
title: 30. Reducing a fraction
---

{% include menu.html %}

*Compose a fraction from the two given integers—numerator and denominator—and reduce it to lowest terms.*

5/15 and 16/280 are examples of fractions that can be reduced. The final results of this task are 1/3 and 2/35. Generally, the algorithm of reducing a fraction requires searching for the greatest common divisor, and then dividing both numerator and denominator by that number.

There is a built-in operator `gcd` that returns the greatest common divisor, so you can use it to solve the task (notice that `gcd` is used as an operator, not a function):

```raku
my $a = 16;
my $b = 280;

my $gcd = $a gcd $b;
say $a/$gcd; # 2
say $b/$gcd; # 35
```

That is a classical solution, but Raku offers something much more magical— the Rational data type `Rat`.

```raku-static
my Rat $r = $a/$b;
say $r.numerator;   # 2
say $r.denominator; # 35
```

The `Rat` value keeps its parts as two integers, which are accessible via the `numerator` and `denominator` methods. The `dd` routine gives you the instant insight:

```raku-static
dd $r; # Rat $r = <2/35>
```

{% include nav.html %}

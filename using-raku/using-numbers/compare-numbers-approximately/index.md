---
title: 25. Compare numbers approximately
---

{% include menu.html %}

*Compare the two non-integer values approximately.*

Comparing non-integer numbers, which are represented as floating-point numbers is often a task that requires approximate comparison.

There is the `=~=` operator, called the approximately-equal operator, which checks if its operands are close enough to each other.

```raku
say 1/1000 =~= 1/1001;         # False
say 1/1E20 =~= 1 / (1E20 + 1); # True
```

The result of the approximate comparison is `True` if the difference is less than the value set in the `$*TOLERANCE` constant, which is equal to `1E-15`.

Notice that in Raku, a number in a scientific notation is a floating-point number, while other representations, such as `0.5` or `1/2`, or `<1/2>`, or even `½`, are the values of the `Rat` type (Rat stands for rational).

Rational numbers are stored as two integer values, the numerator and the denominator. Computations with such numbers, therefore, do not loose accuracy. Compare the results of the following classical example, with a similar program in other languages:

```raku
say 0.1 + 0.2 - 0.3; # 0
```

Raku prints an exact zero, even if you try to print the result with many digits after the decimal point:

```raku
'%.20f'.printf(0.1 + 0.2 - 0.3); # 0.00000000000000000000
```

This is very nice of Raku, isn’t it?

{% include nav.html %}

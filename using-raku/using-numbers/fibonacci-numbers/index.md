---
title: 21. Fibonacci numbers
---

{% include menu.html %}

*Print the Nth Fibonacci number.*

Fibonacci numbers are defined by the recurring formula:

./ = ./01 + ./03.

You can assign two values at a time (see Task 48, Swap two values). You can use that technique for calculating the next Fibonacci number from the previous two. To bootstrap the algorithm, the two first values are needed. In one of the definitions of the Fibonacci row, the first two values are both 1 (sometimes, you may see that the first number is 0).

```raku
my ($a, $b) = (1, 1);
($a, $b) = ($b, $a + $b) for 3 .. 10;
say $b;
```

Another way of generating the sequence is to use the sequence operator. With this operator, you create a lazy list, which calculates its values according to the formula given in the generator argument.

```raku
my @fib = 1, 1, * + * ... *;
say @fib[9];
```

The `@fib` array is a sequence. Its first two elements are both 1, but the rest are defined by the formula `* + *`. This code creates an anonymous block that is equivalent to the body of a function with two arguments: `{$a + $b}`. Thus, the element is a sum of its two neighbours. The right end of the sequence is specified as `*`, which means that it generates numbers infinitely, based on the demand.

The next line just takes the 10th element of the array and prints its value:

{% include nav.html %}

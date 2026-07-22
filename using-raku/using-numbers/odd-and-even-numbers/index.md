---
title: 24. Odd and even numbers
---

{% include menu.html %}

*Print the first ten odd numbers. Print the first ten even numbers.*

Odd numbers are those that have a remainder after division by 2. This fact can be directly exploited in filtering the numbers and printing only those that match this definition.

```raku
.say if $_ % 2 for 1 .. 20;
```

To print even numbers, negate the condition by choosing another keyword: `unless`, instead of `if`:

```raku
.say unless $_ % 2 for 1 .. 20;
```

Numbers can be filtered using the `grep` built-in function:

```raku
.say for grep {$_ % 2}, 1..20;
```

For the odd numbers, negate the condition by using the divisibility operator, which returns `True` when its first operand is divisible by the second with no remainder:

```raku
.say for grep {$_ %% 2}, 1..20;
```

Another interesting approach is using a sequence. Show the first elements of it, and the rest are generated automatically:

```raku
my @odd = 1, 3 ... *;
say @odd[^10];
```

To print the even numbers, change the sample:

```raku
my @even = 2, 4 ... *;
say @even[^10];
```

{% include nav.html %}

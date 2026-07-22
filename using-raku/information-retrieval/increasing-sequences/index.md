---
title: 64. Increasing sequences
---

{% include menu.html %}

*Check if the given array contains increasing (or decreasing) numbers.*

Given the list of numbers in an array, the task is to tell if all of them are sorted in ascending or descending order.

Take an array:

```raku-static
my @data = 3, 7, 19, 20, 34;
```

The reduction operators offer a very expressive and simple way to find the answer in one go:

```raku-static
say [<] @data;
```

With the values listed above, this program prints `True`. Change the array to break the increasing sequence, and the program prints `False`.

You will not be surprised to find out that to check whether the array is sorted in decreasing order, the code is as follows:

```raku-static
say [>] @data;
```

Using reduction operators is equivalent to inserting the main operator between the elements of the array, so `[<] @data` is the same as the following chain of comparison operations:

```raku-static
say @data[0] < @data[1] < @data[2] < @data[3] < @data[4];
```

By the way, Raku’s ability to understand chained operations is very handy in the `if` conditions, for example:

```raku
my $x = 15;
say 'ok' if 10 < $x < 20;
```

{% include nav.html %}

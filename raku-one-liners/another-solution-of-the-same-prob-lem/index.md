---
title: Another solution of the same prob- lem
---

{% include menu.html %}

Here is another solution of the problem. The task was to count all Sundays that fall on the first of the month in the XX century.

Last time, we were scanning all the days in the whole century, selecting the ones that are Sundays `(.day-of-week == 7)` and are the first of the month

```
(.day == 1).
```

It is possible to make a more efficient algorithm. As we are only interested in the first days of the month, there is no need to scan all 36525 days for 100 years. Looking at only 1200 days that are the first day of each month between 1901 and 2000 is enough.

So, we need two nested loops: over the years and over the months. Do we need two `for`s? Not necessarily. Let’s use the `X` operator (see Chapter 6 for more details on it).

And here is our new one-liner:

```raku
(gather for 1901..2000 X 1..12 {
    take Date.new(|@_, 1)
}).grep(*.day-of-week == 7).elems.say;
```

The `for 1901..2000 X 1..12` loop goes over each month in the XX century. For each, we create a `Date` object by calling a constructor with three arguments.

Notice that inside the loop, you can use both `$_[0]` and `$_[1]`, and `@_[0]` and `@_[1]`. In the first case, the `$_` variable contains a list of two elements, while it is an array `@_` in the second one. The shortest code is achieved if you are just using a dot to call a method on the topic (default) variable: `.[0]` and

```
.[1].
```

Instead of `Date.new(|@_, 1)`, you can type `Date.new(.[0], .[1], 1)`. The `|@_` syntax is used to unroll an array, as otherwise Raku thinks that you are passing an array as a first argument.

All first days of the months are collected in a sequence with the help of the `gather`—`take` pair.

The final step is a `grep` as before, but this time we only need to select Sundays, so a single `*.day-of-week == 7` condition is enough.

The call of the `elems` method returns the number of the elements in the list, which is the number of Sundays that we are looking for. Thus, print it with `say`.

Based on a very relevant comment from a reader, here’s even better and simpler way of the solution, where the `+` prefix operator is used to cast a list to its length:

```raku
say +(1901..2000 X 1..12).map(
    {Date.new(|@_, 1)}
).grep(*.day-of-week == 7);
```

{% include nav.html %}

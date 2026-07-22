---
title: Grepping multiples of 3 and 5
---

{% include menu.html %}

The task is to find the sum of all multiples of 3 and 5 below 1000. The first elements of the row of our interest are 3, 5, 9, 15, 20, 21, etc. You can already see that some of them, such as 15, are multiples of both 3 and 5, so it is not possible to add up multiples of 3 and 5 separately.

The short story is here:

```raku
say sum((1..999).grep: * %% (3 | 5))
```

Now, let us decipher it.

What we need is to filter the numbers that are multiples of either 3 or 5. If you re-read the previous sentence, a bell should ring: in Raku, this can be achieved with junctions, previously known as quantum superpositions. To test if a number is dividable by either 3 or 5, write the following:

```raku-static
$x %% 3 | 5
```

By the way, `%%`, the divisibility operator, is a very sweet thing that helps avoiding negations in Boolean tests, which you would have written as follows if you only have a single percent:

```raku-static
!($x % (3 | 5))
```

OK, the main condition is ready, let us scan the numbers between 1 and (including) 999:

```raku-static
(1..999).grep: * %% (3 | 5)
```

A few more interesting language elements appear here. For example, the `WhateverCode` block, which was introduced by a `*` character (see Chapter 6). Together with the colon-form method calls, it allows to get rid of a nested pair of braces and parentheses. Without the `*`, the code would be more complicated:

```raku-static
(1..999).grep({$_ %% (3 | 5)})
```

The numbers are filtered (grepped if you prefer), and it’s time to add them up and print the result. We come to the final one-liner shown at the beginning of this section.

Of course, instead of writing `say sum(...)` one could call a method or two as shown here:

```raku
((1..999).grep: * %% (3 | 5)).sum.say
```

As a bonus track, here’s my first solution which is much longer than a oneliner:

```raku
sub f($n) {
    ($n <<*>> (1...1000 / $n)).grep: * < 1000
}

say (f(3) ∪ f(5)).keys.sum;
```

{% include nav.html %}

---
title: 28. List of prime numbers
---

{% include menu.html %}

*Print the list of the first ten prime numbers.*

In Task 27, Prime numbers, we’ve seen how to check if the given number is prime. To print the list of the first ten numbers, organize a lazy list. The code is quite compact:

```raku
my @numbers = grep {.is-prime}, 1..*;
say @numbers[^10];
```

The first line has to be read from right to left. The lazy list `1..*` is filtered with the grep function, and another lazy list resides in the `@numbers` variable.

Then, the first ten elements are taken and printed:

```
(2 3 5 7 11 13 17 19 23 29)
```

It is possible to use the colon to pass arguments to functions. The aboveshown code can be rewritten differently:

```raku
my @numbers = (1..*).grep: *.is-prime;
say @numbers[^10];
```

Notice that the two usages of `*` mean different things here. The range of `1..*` is replaceable with an open-end range `^∞` or `^Inf`.

```raku
my @numbers = (^Inf).grep: *.is-prime;
say @numbers[^10];
```

Finally, make a selection of the first ten elements directly:

```raku
say ((^∞).grep: *.is-prime)[^10];
```

{% include nav.html %}

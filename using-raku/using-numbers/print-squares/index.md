---
title: 22. Print squares
---

{% include menu.html %}

*Print the squares of the numbers from 1 to 10.*

To print the squares for a range of numbers, a loop is required. If the body of the loop is simple, you can use the postfix notation:

```raku
say $_ ** 2 for 1..10;
```

The `$_` variable is a loop variable, which receives the new value on each iteration.

Raku offers the `**` operator for calculating powers, so it can be used instead of the straightforward multiplication `$_ * $_`.

In the case of you needing a named loop variable, choose another form of a loop:

```raku
for 1..10 -> $x {
    say $x * $x;
}
```

Notice that there are no parentheses around the range in the `for` loop.

We also can create a list of squares using the `map` function, as demonstrated in the following example:

```raku
.say for map {$_ ** 2}, 1..10;
```

Here, the range `1..10` is first converted to the list, each element of which is a square of the corresponding element of the initial list, and then it is printed one by one as before.

The dot before `say` means calling the `say` method on the default variable, so both `$_.say` and `.say` are equivalent.

{% include nav.html %}

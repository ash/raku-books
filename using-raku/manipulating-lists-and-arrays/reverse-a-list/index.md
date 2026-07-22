---
title: 49. Reverse a list
---

{% include menu.html %}

*Print the given list in reverse order.*

Start with an array of integer numbers.

```raku-static
my @a = (10, 20, 30, 40, 50);
```

To reverse the array, call the `reverse` method on it.

```raku-static
say @a.reverse;
```

This line prints the required result:

```
(50 40 30 20 10)
```

Notice that the initial array stays unchanged. The `reverse` method creates a new sequence and returns it.

The same method works with other types of data that can be converted to a sequence, for example, ranges.

Print a range in reversed order:

```raku
my $range = 10..15;
say $range;
say $range.reverse;
```

Again, the original range is not changed, and the returned value is not a range but a sequence. Compare the results of printing an original value of `$range` with what the `reverse` method returns:

```
10..15
(15 14 13 12 11 10)
```

{% include nav.html %}

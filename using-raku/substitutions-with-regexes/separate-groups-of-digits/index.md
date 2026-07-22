---
title: 79. Separate groups of digits
---

{% include menu.html %}

*Put commas between the three-digit groups in a big number.*

The task is to print an integer number, for example, `1234567890`, in the form

```
of 1,234,567,890.
```

Here is a possible solution that uses a lot of Raku facilities:

```raku-static
$n ~~ s/<?after \d> (\d ** 3)+ $/{$0.map(',' ~ *).join}/;
```

On the top level, we’ve got a substitution `s///`. The pattern is anchored to the end of the string: `s/...$//`. From the end of the string, groups of three digits are searched: `(\d ** 3)+`. A single `\d` matches a digit, and the `**` quantifier requires exactly three of them. The second quantifier, `+`, allows more than one such groups.

A dot may only follow at least one digit. To avoid converting six-digit numbers to something like `.123.456`, a look-behind assertion `<?after \d>` is inserted, which insists that there is a digit before the first group of three digits. The whole replacement only happens if there are more than four digits in the original number.

The second part of the substitution is an executable code: `s//{...}/`. After a successful match, the three-digit groups appear in the match object `$0`. Because of the `+` quantifier, you can treat this object as an array.

First, each element is translated to a string with a comma in front of it: `map(',' ~ *)`. Using the `*` character creates a `WhateverCode` block, which is equivalent to `{',' ~ $_}`. It is also possible to rewrite the map operation using the string interpolation: `map({",$_"})`.

Finally, transformed parts are joined together, using the `join` method call. The `$n` variable now contains a string with the desired result.

{% include nav.html %}

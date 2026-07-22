---
title: min, max
---

{% include menu.html %}

`min` and `max` return, correspondently, the minimum and maximum value of their operands.

```raku
say 20 min 10;         # 10
say 'three' max 'two'; # two (sorted alphabetically)
```

`?? !!` is the ternary operator. It works as its counterpart `? :` in Perl 5. The characters are doubled to avoid the mixture with infix operators `?` and `!`, which change the context of their operands.

```raku
say rand < 0.5 ?? 'Yes' !! 'No';
```

`=` assigns a value to a variable.

`=>` creates an object of the `Pair` type. The Pair is a “key; value” combination, like those used in hashes. In the code, it is not always necessary to quote the key values.

```raku-static
my $pair = alpha => "one";

my %data = jan => 31, feb => 28, mar => 31;
```

`,` creates a `List` object. Note that this operator, as a few mentioned above, can be chained to accept more than two operands.

```raku
my $what = (1, 2, 3);
say $what.WHAT; # (List)
```

The comma is also used as a separator of parameters passed to the subroutine.

To create an empty list, use a pair of parentheses `()`.

{% include nav.html %}

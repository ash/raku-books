---
title: 19. π
---

{% include menu.html %}

*Print the value of π.*

The value of ! is accessible with no additional modules:

```raku
say π;
```

This instruction, not a surprise, prints the desired value:

```
3.14159265358979
```

As you may have noticed, a non-ASCII character was used in the code. Raku assumes that the source code is encoded as UTF-8 by default. Instead, a non-Unicode version can be used, too:

```raku
say pi;
```

There are a couple more built-in constants: `tau` and `e`; both of them have Unicode variants: " and # (character code `0x1D452`):

```raku
say τ;
say e;
```

The value of `tau` is equal to 2!, and the above program prints the following result:

```
6.28318530717959
2.71828182845905
```

It is also worth knowing that there’s a special constant for presenting infinity: `Inf` or ∞. This number is bigger than any other (reasonably big) number; either an integer or a floating-point value.

```raku
say 1E120 < ∞; # Prints True
```

{% include nav.html %}

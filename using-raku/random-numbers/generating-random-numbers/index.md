---
title: 32. Generating random numbers
---

{% include menu.html %}

*Generate a random number between 0 and N.*

Use the `rand` method, which returns a random number between 0 and the value of its invocant:

```raku
say 1.rand;    # between 0 and 1
say 2.5.rand;  # between 0 and 2.5
say pi.rand;   # between 0 and 3.14…
```

The `rand` method is defined in the `Cool` class, which is the base class for the `Int`, `Num`, and `Rat` types. It always returns a floating-point value of the `Num` data type.

To generate random integer numbers, call the `Int` method:

```raku
say 10.rand.Int; # Either 0, or 1, 2, 3, 4, 5, 6, 7, 8, or 9 but not 10
```

The `srand` function initializes the random numbers generator. The function expects an integer argument:

```raku-static
srand(1);
```

After setting the seed, the `rand` method starts generating numbers in the same sequence.

```raku-nobrowser
srand(1);
my $a = 10.rand;

srand(1);
my $b = 10.rand;

say $a == $b; # True
```

{% include nav.html %}

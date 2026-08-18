---
title: Numbers
---

{% include menu.html %}

In Perl, a number is a number. A scalar holds an integer or a float, the
interpreter decides which as it goes along, and when the integer grows too large
it silently becomes a float and you quietly lose precision. It works, most of the
time, and the times it does not — money, big factorials, `0.1 + 0.2` — are a rite
of passage.

Raku replaces that single fuzzy notion with a small family of cooperating types,
the *numeric tower*: `Int`, `Rat`, `Num`, and `Complex`, with `FatRat` in
reserve. You rarely name them by hand — literals pick the right type for you — but
knowing who is who explains why Raku's arithmetic behaves so much better out of
the box.

## Integers are arbitrary-precision by default

Here is the Perl surprise that every programmer meets sooner or later:

```perl
print 2 ** 100, "\n";     # 1.26765060022823e+30
```

The result should be an exact 31-digit integer, but `**` produced a float, so you
get scientific notation and a fistful of lost digits. The fix in Perl is a
module:

```perl
use bigint;
print 2 ** 100, "\n";     # 1267650600228229401496703205376
```

In Raku there is nothing to switch on. An integer literal is an `Int`, and `Int`
is arbitrary-precision, always:

```raku
say 2 ** 100;             # 1267650600228229401496703205376
say (2 ** 100).WHAT;      # (Int)
```

There is no separate "big integer" type to reach for and no threshold at which
numbers quietly degrade. `2 ** 64` is an `Int`, `2 ** 1000` is an `Int`, and both
are exact. This is the single most reassuring difference in the whole tower: you
can stop thinking about integer overflow.

## Rationals: decimals that add up

The other classic Perl papercut is floating-point decimals:

```perl
printf "%.17g\n", 0.1 + 0.2;   # 0.30000000000000004
```

The literal `0.1` cannot be represented exactly in binary floating point, so the
sum drifts. In Raku, a decimal literal is not a float at all — it is a `Rat`, an
exact ratio of two integers. `0.1` *is* the fraction 1/10, stored as numerator
and denominator, so the arithmetic is exact:

```raku
say 0.1 + 0.2;            # 0.3
say 0.1 + 0.2 == 0.3;     # True
```

You can look inside a `Rat`. It knows its own `.numerator` and `.denominator`,
and `.nude` (**nu**merator–**de**nominator) hands you both at once:

```raku
my $r = 1 / 3;
say $r.WHAT;              # (Rat)
say $r.numerator;         # 1
say $r.denominator;       # 3
say $r.nude;              # (1 3)
```

There is one thing to watch. When you print a `Rat`, its string form is a decimal
rounded for readability, not the exact fraction:

```raku
say 1 / 3;               # 0.333333
say (1 / 3).nude;        # (1 3)   — the real value
```

So `1/3` is stored exactly and computes exactly; it merely *displays* as a
rounded decimal. When you need to see or compare the true value, reach for
`.nude` or the numerator and denominator.

## Division: `/` gives a Rat, `div` stays integer

This follows directly. In Perl, `/` is always floating-point division and there
is no integer-division operator — you divide and then call `int`:

```perl
my $x = 7 / 2;            # 3.5
my $q = int(7 / 2);       # 3
```

In Raku, `/` between two integers produces a `Rat`, not a float, so it is exact
and it remembers it is really a fraction:

```raku
say 7 / 2;               # 3.5
say (7 / 2).WHAT;        # (Rat)
```

When you actually want integer division, ask for it by name with `div`, and use
`mod` for the integer remainder:

```raku
say 7 div 2;             # 3
say (7 div 2).WHAT;      # (Int)
say 7 mod 3;             # 1
```

The `%` operator still gives a remainder, as in Perl, but `mod` is the
integer-only sibling of `div`. For positive operands they agree; the pairing to
remember is `div`/`mod` for integers, `/`/`%` for the general case.

## Num: floating point when you ask for it

Floating point has not gone away — it is the right tool for scientific
computation and anything involving irrational results. In Raku it is the `Num`
type, and you summon it with an exponent literal or by coercion:

```raku
say 1e10;                # 10000000000
say (1e10).WHAT;         # (Num)
say (1 / 3).Num;         # 0.3333333333333333
```

Functions whose results are inherently irrational return a `Num` even when their
input was an integer — `.sqrt` is the everyday example:

```raku
say 2.sqrt;              # 1.4142135623730951
say (2.sqrt).WHAT;       # (Num)
```

The mental model: `Int` and `Rat` are exact, `Num` is fast-but-approximate. Raku
keeps you on the exact side by default and only moves to `Num` when the maths
genuinely demands it or you explicitly request it.

## Complex and FatRat

Two members of the tower you will meet less often but should recognise.

A `Complex` number is written with an `i` suffix on the imaginary part, and it
behaves like any other number:

```raku
say 2 + 3i;              # 2+3i
say (2 + 3i).WHAT;       # (Complex)
say (2 + 3i).abs;        # 3.605551275463989
```

A `FatRat` is a `Rat` with no size limit on its numerator and denominator. An
ordinary `Rat` keeps its denominator within machine-integer range and falls back
to `Num` if a calculation would overflow it; a `FatRat` never does, staying exact
however big the fraction grows:

```raku
my $f = 1.FatRat / 3;
say $f.WHAT;                          # (FatRat)
say (10 ** 100).FatRat.denominator;   # 1
```

You reach for `FatRat` only when you need extreme-precision fractions; the plain
`Rat` covers day-to-day decimals.

## Literals: radixes, underscores, and fractions

Perl's numeric literals mostly carry over, and Raku adds a couple of niceties.
Hexadecimal, octal, and binary use the familiar prefixes — note that octal is
`0o`, not a bare leading zero:

```raku
say 0xff;                # 255
say 0o17;                # 15
say 0b1010;              # 10
```

For any other base, the general radix form `:base<digits>` does the job:

```raku
say :16<dead_beef>;      # 3735928559
say :2<1010>;            # 10
```

Underscores may be used as digit separators anywhere inside a number, exactly as
in Perl:

```raku
say 1_000_000;           # 1000000
```

And because `Rat` is a real type, you can write a fraction directly as a literal
expression and it stays exact:

```raku
say (1 / 3 + 1 / 6).nude;   # (1 2)   — exactly one half
```

## Coercion and numeric context

Turning a value into a specific type is done with an uppercase coercion method
named after the type: `.Int`, `.Rat`, `.Num`, `.Str`.

```raku
say "3.14".Rat;          # 3.14
say "42".Int;            # 42
say 42.Str;              # 42
```

To force a string into a number the quick way, use the unary `+`, which is the
numeric-context operator — the Raku spelling of Perl's `0 + $str` idiom:

```raku
say +"42";               # 42
say +"5" + 3;            # 8
```

Here the string parser is noticeably smarter than Perl's. It understands radix
prefixes and underscores, where Perl would stop at the first non-digit:

```raku
say +"0xff";             # 255      (Perl's 0 + "0xff" is 0)
say +"1_000";            # 1000     (Perl's 0 + "1_000" is 1)
```

The mirror image is string context, which you get from `~` (the concatenation
operator we met in Chapter 1) or from `.Str`. So `~` stringifies and `+`
numifies, and unlike Perl there is no single operator that guesses which you
meant:

```raku
say 5 ~ 3;               # 53   (string context)
say 5 + 3;               # 8    (numeric context)
```

## Useful methods on numbers

Because every number is an object (Chapter 2), the standard operations are
methods you can chain. A representative handful, all verified:

```raku
say (-5).abs;            # 5
say 17.is-prime;         # True
say 255.base(16);        # FF
say 3.7.floor;           # 3
say 3.2.ceiling;         # 4
say 3.567.round(0.01);   # 3.57
say (-3).sign;           # -1
```

`.round` takes an optional unit, so `.round(0.01)` rounds to two decimal places
and a bare `.round` rounds to the nearest integer. `.sign` returns `-1`, `0`, or
`1`. These read naturally in a chain: `say (-3.7).abs.ceiling;` gives `4`.

Finally, `**` deserves one more look, because it is where the arbitrary-precision
`Int` earns its keep. A negative integer exponent even keeps you in exact-rational
territory rather than dropping to a float:

```raku
say 10 ** -3;            # 0.001
say (10 ** -3).WHAT;     # (Rat)
```

That is the numeric tower in one sentence: exact by default, approximate only when
you ask. With numbers behaving themselves, the next chapter turns to the other
half of everyday scalars — strings.

{% include nav.html %}

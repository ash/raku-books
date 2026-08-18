---
title: Operators You Already Know
---

{% include menu.html %}

Most of Perl's operators survive the move to Raku unchanged, or nearly so. You
can add with `+`, multiply with `*`, and take a remainder with `%` exactly as
before. This chapter is the reassuring one: it walks the operators you already
carry in your fingers, points out the handful that were renamed or tightened, and
flags the gotchas that catch Perl programmers out of habit. The genuinely new
machinery — reductions, hypers, cross and zip — waits for Chapter 11.

## Arithmetic

The five arithmetic operators are identical in spelling in both languages —
`+`, `-`, `*`, `**` (exponentiation), and `%` (remainder):

```raku
say 2 + 3;      # 5
say 6 * 7;      # 42
say 2 ** 10;    # 1024
say 17 % 5;     # 2
```

The one to watch is division. In Perl, `/` gives you a floating-point number.
In Raku, dividing two integers gives you a `Rat` — an exact fraction — so the
result prints as you would write it by hand and never drifts:

```raku
say 7 / 2;          # 3.5
say (7 / 2).WHAT;   # (Rat)
```

Chapter 6 covers the numeric tower in full; here it is enough to know that `+`,
`-`, `*`, and `**` behave as you expect, and `/` is quietly more honest.

## String concatenation: `.` becomes `~`

You met this in Chapter 1, but it belongs in any list of operators. Perl joins
strings with a dot:

```perl
say 'Hello, ' . 'World!';    # Hello, World!
```

In Raku the dot means *call a method* — uniformly, on everything — so
concatenation had to move out of the way. It moved to the tilde:

```raku
say 'Hello, ' ~ 'World!';    # Hello, World!
```

Think of `~` as "the string operator" and the association will pay off later:
the whole string-flavoured family (`~=`, and the bitwise `~&`, `~|`, `~^` below)
is built on it.

## Repetition: `x` for strings, `xx` for lists

Perl overloads `x` for both jobs — repeat a string, or repeat a list in list
context:

```perl
say 'ab' x 3;              # ababab
my @three = (1, 2) x 3;    # (1,2,1,2,1,2)
```

Raku splits the two jobs into two operators, which removes the context guessing.
`x` always repeats a *string*; `xx` repeats a *list*:

```raku
say 'ab' x 3;             # ababab
say (1, 2) xx 3;          # ((1 2) (1 2) (1 2))
```

Note that `xx` keeps the structure — you get a list of three lists, not a
flattened one. That is deliberate; flattening in Raku is something you ask for,
not something that happens behind your back.

## Comparison: numeric versus string

The split between numeric and string comparison is exactly as in Perl, and the
spellings are identical. Numeric: `==`, `!=`, `<`, `<=`, `>`, `>=`. String:
`eq`, `ne`, `lt`, `le`, `gt`, `ge`.

```raku
say 10 == 10.0;            # True
say '10' eq '10.0';        # False
say 'apple' lt 'banana';   # True
```

The one difference you can feel is what a comparison *returns*. Perl hands back
`1` or the empty string; Raku returns a proper `Bool`, either `True` or `False`.

### Three-way comparison: `<=>`, `cmp`, and `leg`

Perl has two spaceships: `<=>` for numbers and `cmp` for strings, each
returning `-1`, `0`, or `1`. Raku keeps both names and adds a third, `leg`
(mnemonic: **l**ess/**e**qual/**g**reater), which forces string comparison. The
important change is the return value: instead of a bare number you get an `Order`
enum — `Less`, `Same`, or `More`:

```perl
say 3 <=> 5;        # -1
say 'a' cmp 'b';    # -1
```

```raku
say 3 <=> 5;        # Less
say 'a' cmp 'b';    # Less
say 'a' leg 'b';    # Less
```

Here `cmp` is the smart one — it compares numbers numerically and strings as
strings — while `<=>` coerces to number and `leg` coerces to string. The enum
sorts and stringifies sensibly, so most code that fed a spaceship into `sort`
keeps working; only code that did arithmetic on the raw `-1`/`0`/`1` needs a
second look.

## The ternary changes shape: `?? !!`

This is a pure re-spelling, but a compulsory one. Perl's `?:` becomes `?? !!`:

```perl
my $n = 7;
say $n % 2 ? 'odd' : 'even';     # odd   (Perl: ? and :)
```

```raku
my $n = 7;
say $n % 2 ?? 'odd' !! 'even';   # odd
```

Why the doubling? The single `?` and `:` were needed elsewhere — `:` in
particular now introduces adverbs and named arguments — so the conditional
operator was given a distinctive spelling of its own. Read `??` as "then" and
`!!` as "else".

## Ranges, and how to exclude an endpoint

The range operator is still `..`, and still builds a range from both endpoints
inclusive:

```raku
say (1 .. 5);       # 1..5
say (1 .. 5).list;  # (1 2 3 4 5)
```

What is new is a family of variants that exclude one or both endpoints. Put a `^`
on the side you want to drop:

```raku
say (1 ^.. 5).list;    # (2 3 4 5)   — exclude the low end
say (1 ..^ 5).list;    # (1 2 3 4)   — exclude the high end
say (1 ^..^ 5).list;   # (2 3 4)     — exclude both
```

And a `^` as a *prefix* gives you the extremely common "zero up to but not
including N" range, perfect for indexing:

```raku
say (^5).list;         # (0 1 2 3 4)
.say for ^3;           # 0 1 2  (each on its own line)
```

`^5` is Raku's answer to Perl's `for (0 .. $#array)` and `for (0 .. @a - 1)` —
the off-by-one bookkeeping disappears.

## Chained comparisons

Older Perl read `1 < $x < 10` the wrong way: it evaluated `1 < $x` first, got a
boolean, then compared *that* to `10`. Modern Perl chains comparisons the way
mathematics does:

```perl
use v5.32;

my $x = 5;
say "in range" if 1 < $x < 10;      # in range
```

and so does Raku:

```raku
my $x = 5;
say 1 < $x < 10;      # True
say 1 < 20 < 10;      # False
```

Each term is evaluated once and each neighbouring pair is compared, with an
implicit `and` between them. You can mix operators too: `0 <= $i < @a.elems`
reads exactly as intended. This alone retires a lot of fiddly two-part
conditions.

## Increment, decrement, and magic strings

`++` and `--` work as before, in both prefix and postfix positions. Raku also
keeps Perl's delightful *magic string increment*, where `++` on an alphanumeric
string carries like an odometer:

```raku
my $s = 'aa';  $s++;  say $s;    # ab
my $s2 = 'Az'; $s2++; say $s2;   # Ba
my $s3 = 'a9'; $s3++; say $s3;   # b0
my $s4 = 'zz'; $s4++; say $s4;   # aaa
```

The rules match Perl: it increments within `a-z`, `A-Z`, and `0-9`, carrying
into the next position and growing the string when the leftmost character rolls
over.

## Assignment operators

Every binary operator gets a matching assignment form, just as in Perl, and
they compose from the operators above. The only ones that *look* different are
the ones whose base operator was renamed:

```raku
my $a = 10;  $a += 5;   say $a;    # 15
my $s = 'x'; $s ~= 'y'; say $s;    # xy   (was .= in Perl)
my $m = 2;   $m **= 3;  say $m;    # 8
my $p = 3;   $p x= 3;   say $p;    # 333
```

If you catch yourself typing `.=` for string append, that is muscle memory from
Perl; the Raku form is `~=`.

## Defined-or: `//`

The defined-or operator survives intact — indeed it was another idea Perl
borrowed back from the Raku design. It returns its left operand if that operand
is defined, and the right one otherwise:

```raku
my $config;
say $config // 'default';    # default
```

Its assignment form `//=` is just as useful for "set this only if it has no value
yet". Because Raku distinguishes defined from merely-false values cleanly, `//`
is usually what you want over `||` when a legitimate `0` or `''` must survive.

## Boolean logic

Both the symbolic operators (`&&`, `||`, `!`) and the low-precedence word forms
(`and`, `or`, `not`, `xor`) carry over unchanged. As in Perl they
short-circuit and return the deciding operand, not a coerced boolean:

```raku
say True && False;   # False
say 0 || 7;          # 7   (returns the operand, not just True)
say (5 and 6);       # 6
```

The precedence relationship is the same trap it always was: `and`/`or` bind
looser than `=`, which is exactly why they are handy for flow control and
dangerous in assignments.

## Bitwise operators are renamed and typed

Here is the one family that changed spelling wholesale. In Perl the bitwise
operators are `&`, `|`, `^`, `<<`, `>>`, and they quietly switch between numeric
and string behaviour depending on their operands — a long-standing source of
subtle bugs. Raku removes the guesswork by giving each *type* its own prefixed
set.

Numeric bitwise operators take a `+` prefix:

```raku
say 5 +& 3;     # 1
say 5 +| 2;     # 7
say 5 +^ 1;     # 4    (xor)
say 1 +< 4;     # 16   (left shift)
say 16 +> 2;    # 4    (right shift)
```

String bitwise operators take a `~` prefix (the string sigil again), operating
on characters:

```raku
say 'a' ~| 'b';   # c
```

And boolean bitwise operators take a `?` prefix, returning a `Bool`:

```raku
say True ?& False;   # False
say True ?| False;   # True
say True ?^ True;    # False
```

You will not reach for these often, but when you do, the prefix tells you — and
the reader — exactly which interpretation you meant. No more `use integer` or
accidental string-wise `&`.

## A first look at smartmatch: `~~`

Perl's smartmatch was famously unpredictable and ended up marked experimental.
Raku rebuilt it on a clear rule: `$x ~~ $y` asks "does `$x` match `$y`?", and it
is *the right operand* that decides what "match" means. Against a type it is a
type check; against a range, membership; against a regex, a pattern match:

```raku
say 5 ~~ Int;        # True
say 5 ~~ 1..10;      # True
say 'foo' ~~ /o/;    # ｢o｣   (the matched text)
say 5 ~~ 6;          # False
```

That is only a taste — smartmatch is the engine behind `given`/`when`, and it
gets its full treatment in Chapter 13.

With the familiar operators behind us — the ones you mostly already know — we can
turn to the part of Raku that has no Perl equivalent at all: the meta-operators
and the new operators built on top of everything here. That is Chapter 11.

{% include nav.html %}

---
title: The Big Picture
---

{% include menu.html %}

Before we start translating individual constructs, it is worth stepping back to
see the shape of the journey. Raku is not a new language that happens to look
like Perl; it grew out of the same design sensibility, and most of your instincts
carry over. Sigils, `my`, hashes, regexes, `TIMTOWTDI` — they are all here. What
changed is, for the most part, changed *for a reason*, and once you see the
handful of big ideas behind those changes, the rest of the book will read less
like a list of surprises and more like a set of natural consequences.

This chapter sketches those big ideas. Do not worry about mastering anything
here — each topic gets its own chapter later. Think of this as a map.

## Sigils stay, but they stop shifting

In Perl, the sigil tells you what you are *doing*, not what the variable *is*.
You declare an array with `@`, but to reach a single element you switch to `$`,
because you are now talking about one scalar:

```perl
my @colours = ('red', 'green', 'blue');
say $colours[0];          # red   — note the $
my @first_two = @colours[0, 1];
my %ages = (Alice => 30, Bob => 25);
say $ages{Alice};         # 30    — note the $
```

That sigil-switching is the single most common thing Perl programmers stop
noticing they do. Raku removes it. The sigil now names the *variable*, and it
never changes, no matter how much of it you access:

```raku
my @colours = 'red', 'green', 'blue';
say @colours[0];          # red   — the sigil stays @
my @first-two = @colours[0, 1];
my %ages = Alice => 30, Bob => 25;
say %ages<Alice>;         # 30    — the sigil stays %
```

This is the change you will feel most often in the first hour, and the one most
likely to trip you up out of habit. The rule is simple: **the sigil belongs to
the container, so it is invariant.** `@array[0]` is a single element; the `[…]`
is what says "one element", not the sigil.

You will also notice `%ages<Alice>` above. Angle brackets are Raku's shorthand
for subscripting a hash with a constant string — the equivalent of Perl's
`$ages{'Alice'}` or the bareword `$ages{Alice}`. When the key is in a variable,
you use braces: `%ages{$name}`. Chapters 4 and 5 cover arrays and hashes in full.

## Everything is an object

In Perl, some things are objects (blessed references) and most things are not.
In Raku, essentially everything is an object with methods you can call — numbers,
strings, literals, even the result of an expression. We already used this in
Chapter 1 when we wrote `'Hello, World!'.uc.say`. It goes further than strings:

```raku
say 42.sqrt;              # 6.48074069840786
say (1..100).sum;         # 5050
say "hello".tc;           # Hello  (title-case)
say [3, 1, 2].sort;       # (1 2 3)
```

This is why the dot is no longer the concatenation operator (that job went to
`~`): the dot means "call a method", uniformly, on everything.

You can even ask an object what it is. Two introspection tools you will reach for
constantly while learning are `.WHAT`, which returns the type, and `.^name`,
which returns the type's name as a string:

```raku
say 42.WHAT;              # (Int)
say 3.14.WHAT;            # (Rat)
say "x".WHAT;             # (Str)
say (1, 2, 3).WHAT;       # (List)
```

Keep `.WHAT` in your back pocket. Whenever Raku does something you did not
expect, asking an expression what type it produced is often the fastest way to
understand why.

## Types are optional — until you want them

Perl has no variable types: a scalar holds whatever you put in it. Raku keeps
that freedom — you can write untyped code exactly as before — but it also lets you
*opt in* to types when they help. This is called gradual typing.

Write nothing, and it works the way you expect:

```raku-static
my $x = 5;
$x = 'now a string';      # fine
```

Add a type, and Raku holds you to it:

```raku-static
my Int $count = 5;
$count = 10;              # fine
$count = 'oops';          # runtime error: Type check failed
```

You are never forced to annotate types, but as programs grow, a well-placed
`Int` or `Str` turns a class of silent bugs into loud, immediate errors. The
same idea reappears — more powerfully — in subroutine signatures (Chapter 15) and
in the type system proper (Chapter 9).

## Numbers that add up

Here is a small change with a large payoff. In Perl, decimal literals are
floating-point, so the classic surprise applies:

```perl
printf "%.17g\n", 0.1 + 0.2;   # 0.30000000000000004
```

In Raku, a literal like `0.1` is a *rational* number — an exact fraction — so the
arithmetic is exact:

```raku
say 0.1 + 0.2;                  # 0.3
say 0.1 + 0.2 == 0.3;           # True
```

Integers, likewise, are arbitrary-precision by default. No special module, no
`use bigint` — large numbers just work:

```raku
say 2 ** 100;                   # 1267650600228229401496703205376
```

You do not have to do anything to get this; it is simply how numbers behave.
Chapter 6 covers the numeric tower — `Int`, `Rat`, `Num`, `Complex` — in detail.

## There is still more than one way to do it

Raku has not abandoned Perl's most famous slogan. If anything, it doubles down:
the same greeting can be written as a function call, a method call, or a chain,
and none of them is more "correct" than the others.

```raku
say 'Hello, World!';
'Hello, World!'.say;
'Hello, World!'.uc.say;
```

What changed is not the philosophy but the vocabulary. Many things that required
a module, a special variable, or a clever idiom in Perl are now first-class
parts of the language: string interpolation of arbitrary code, function
signatures, exceptions as objects, lazy lists, concurrency primitives. A lot of
this book is really about *unlearning workarounds* — noticing where you used to
reach for a trick, and replacing it with the built-in that now exists.

## A map of what is ahead

The rest of the book follows the shape of things you already know:

- **Variables and data** (Part II) — where sigil invariance, the numeric tower,
  strings, and the shift from references to *containers* live. This is where the
  day-to-day differences concentrate.
- **Operators** (Part III) — the ones you know, then the new meta-operators
  (`[+]`, `»+«`, `X`, `Z`) that fold whole loops into a single expression.
- **Control flow** (Part IV) — familiar loops and conditionals, plus `given`/
  `when` and the phasers that generalise `BEGIN`/`END`.
- **Subroutines** (Part V) — the big one: `@_` gives way to real signatures, and
  multiple dispatch replaces a lot of hand-written argument checking.
- **Regexes and grammars** (Part VI) — the largest syntactic break from Perl,
  and the gateway to Raku's headline feature.
- **Text and I/O, OOP, modules, and modern Raku** (Parts VII–X) — file handling,
  a clean class syntax with roles, the `zef` ecosystem (and calling Perl from
  Raku), then exceptions, functional style, and concurrency.

If you take one thing from this chapter, let it be the three ideas that explain
most of what follows: **sigils are invariant, everything is an object, and types
are there when you want them.** With those in mind, let us start translating.

{% include nav.html %}

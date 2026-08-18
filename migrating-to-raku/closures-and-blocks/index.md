---
title: Closures and Blocks
---

{% include menu.html %}

Perl already has anonymous subroutines and closures, and they behave much as you
remember. What Raku adds is *sugar* — a handful of lighter ways to write a block
of code, each suited to a different situation — and a proper sigil, `&`, for
treating code as data. Once these are in your fingers, callbacks, iterators, and
the whole `map`/`grep`/`sort` family (Chapter 27) read far more cleanly than
their Perl counterparts.

## Anonymous subs and closures carry over

The Perl idiom transfers almost verbatim. An anonymous sub is a value; a
closure is one that captures a variable from its surrounding scope. Here is the
classic counter in Perl:

```perl
use v5.10;

sub make_counter {
    my $n = shift;
    return sub { $n++ };
}
my $c = make_counter(10);
say $c->();   # 10
say $c->();   # 11
say $c->();   # 12
```

And in Raku — note two changes only: the `sub` takes a signature (Chapter 15),
and you call it with `$c()` rather than `$c->()`:

```raku-async
sub make-counter($start) {
    my $n = $start;
    return { $n++ };
}
my $c = make-counter(10);
say $c();     # 10
say $c();     # 11
say $c();     # 12
```

The arrow is gone: a code value stored in a scalar is invoked with plain
parentheses. That single change removes most of the `->` noise from Perl
callback code.

## Pointy blocks: `-> $x { ... }`

Where you wrote `sub ($x) { ... }`, Raku offers a lighter spelling — the *pointy
block*. It is an anonymous block with a signature, minus the `sub` keyword:

```raku
my $add = -> $a, $b { $a + $b };
say $add(3, 4);       # 7
```

You will see pointy blocks everywhere a block needs named parameters: after
`for`, `if`-style constructs, and as arguments to routines. They are the
everyday way to write "a block that takes arguments".

## Bare blocks and the implicit `$_`

A bare `{ ... }` block with no signature still takes an argument — it lands in the
topic variable `$_`:

```raku
my $sq = { $_ ** 2 };
say $sq(9);           # 81
```

This is why `.map({ .uc })` works: inside the block, the leading-dot method call
acts on `$_` (Chapter 3). The bare block is the terse choice when there is
exactly one argument and naming it would only add clutter.

## Placeholder parameters: `$^a`, `$^b`

Sometimes you want more than one argument but still do not want to write a
signature. Use *placeholder* parameters — variables with the `^` twigil. They
declare themselves just by appearing, and — this is the part to remember — they
bind to the arguments *in alphabetical order*, not in the order they are written:

```raku
my $combine = { "$^first-$^second" };
say $combine('a', 'b');   # a-b

my $rev = { "$^b $^a" };
say $rev('x', 'y');       # y x
```

Look carefully at `$rev`. Even though `$^b` is written first, `$^a` sorts earlier,
so the arguments bind as `$^a = 'x'` and `$^b = 'y'` — and the block, which names
`$^b` first, prints `y x`. Writing the placeholders in reverse is how you swap
two arguments. Placeholders are elegant for symmetric two-argument blocks —
`{ $^a <=> $^b }` for a sort, say — but the alphabetical rule surprises everyone
once. When order matters and is not alphabetical, reach for a pointy block
instead.

## The `&` sigil: code as a named thing

Perl uses `&` to talk about a subroutine as a value (`\&foo`, `&$code`). Raku
promotes `&` to a full sigil, on the same footing as `$`, `@`, and `%`. A
variable declared with `&` holds code and can be *called by its bare name*:

```raku
my &double = -> $n { $n * 2 };
say double(10);       # 20
```

Because `&double` is callable by name, it reads just like an ordinary sub — the
difference is that you defined it as a value and can pass it around.

To *accept* a piece of code as a parameter, declare the parameter with `&` too.
Inside the body it is callable by name, no dereferencing required:

```raku-static
sub apply(&code, $val) { code($val) }
say apply({ $_ + 100 }, 5);   # 105
say apply(&double, 7);        # 14
```

Passing `&double` hands over the existing routine by name; the `&` says "the code
itself, do not call it". This is the clean replacement for Perl's `\&subname`.

## `Whatever`: the `*` that builds a closure

One of Raku's most quietly useful tricks: a bare `*` in an expression turns that
expression into a one-argument closure. `* + 1` *is* a function that adds one:

```raku
my $inc = * + 1;
say $inc(41);         # 42

my $half = * / 2;
say $half(10);        # 5
```

This is called `Whatever`-currying, and it produces a `WhateverCode`. It shines
as an argument to higher-order routines, where it removes the ceremony of a full
block:

```raku
say (1..5).map(* ** 2).join(',');   # 1,4,9,16,25
```

`* ** 2` reads as "square of whatever" and needs neither `$_` nor `-> $x`. Each
`*` in an expression becomes one parameter, in left-to-right order — so `* - *`
is a two-argument subtraction.

## Currying with `.assuming`

To fix *some* of a routine's arguments and leave the rest open, call `.assuming`
on it. It returns a new routine with those arguments pre-supplied — partial
application, built in:

```raku
sub power($base, $exp) { $base ** $exp }

my $cube = &power.assuming(*, 3);   # fix the exponent
say $cube(2);                       # 8

my $two-to = &power.assuming(2);    # fix the base
say $two-to(10);                    # 1024
```

The `*` in `.assuming(*, 3)` marks the slot to leave open. This is the tidy
alternative to hand-writing a wrapper closure that just forwards one argument.

## `state` inside a closure

`state` variables (Chapter 3) work inside any block, which gives a counter even
lighter than the `make-counter` version above — the state lives in the block
itself:

```raku
my $ticker = { state $n = 0; ++$n };
say $ticker();        # 1
say $ticker();        # 2
say $ticker();        # 3
```

The `state $n = 0` runs its initialiser once; every later call sees the value
left behind. Where the closure version captures an *outer* `my` variable, the
`state` version keeps its memory *inside*.

## Blocks feed the functional routines

All of this comes together when you pass blocks to `map`, `grep`, `sort`, and
friends — the subject of Chapter 27. Any of the block forms above will do,
whichever reads best:

```raku
say (1..10).grep(* %% 2).join(',');           # 2,4,6,8,10
say <apple banana cherry>.map({ .uc }).join(' ');
                                              # APPLE BANANA CHERRY
```

Compare the Perl originals, which are close but carry more punctuation:

```perl
use v5.10;
say join ',', grep { $_ % 2 == 0 } 1..10;     # 2,4,6,8,10
say join ',', map { $_ ** 2 } 1..5;           # 1,4,9,16,25
```

(`%%` is Raku's "is divisible by" operator, from Chapter 11 — `* %% 2` is a
neat "is even?".)

The through-line of this chapter is that Raku treats a block as an ordinary
value: name it with `&`, pass it, partially apply it, or write it inline with the
lightest syntax the situation allows. That same idea — small pieces of matching
logic composed together — is exactly what powers the next part of the book, where
we leave subroutines behind and take on the largest syntactic change of all:
regular expressions.

{% include nav.html %}

---
title: Types and the Type System
---

{% include menu.html %}

Perl has essentially one rule about the type of a variable: there is no rule. A
scalar holds a number now and a string later, and the language sorts out the
difference when you use it. That freedom is wonderful for quick work and
occasionally the source of a bug that hides for months.

Raku keeps the freedom and adds a dial you can turn. Write no types and the
language behaves much as Perl does. Add a type where it earns its keep and Raku
enforces it, turning a class of silent misbehaviour into a loud, immediate error.
This is *gradual typing*, and getting comfortable with it — especially the
distinction between a type and an instance of it — unlocks signatures (Chapter 15)
and multiple dispatch (Chapter 16) later on.

## Untyped by default

Nothing forces you to annotate anything. A plain scalar is as free as ever:

```raku-static
my $x = 5;
$x = 'now a string';
$x = [1, 2, 3];       # all fine
```

This is the baseline. Everything that follows is opt-in.

## Constraining a variable

Put a type between `my` and the variable and Raku holds the container to it:

```raku-static
my Int $n = 5;
say $n;               # 5
$n = 'oops';          # Type check failed in assignment to $n;
                      #   expected Int but got Str ("oops")
```

The type sits where you already put `my`, so the change from Perl is purely
additive. A typed variable that you do not initialise does not hold `undef`; it
holds the *type itself* as a sensible default:

```raku
my Int $n;  say $n.raku;    # Int
my Str $s;  say $s.raku;    # Str
my @a;      say @a.raku;    # []
my %h;      say %h.raku;    # {}
```

That `Int` sitting in `$n` is the heart of the whole system, and it deserves a
proper introduction.

## Type objects versus instances

In Raku every type is *also a value*. `Int` is not just an annotation you write in
a declaration; it is an object you can pass around, print, and test. It is called
a *type object*, and it stands for "an `Int`, but not any particular one":

```raku
say Int.WHAT;         # (Int)
say Int.defined;      # False
say 42.defined;       # True
```

This is the cleanest replacement for Perl's overloaded `undef`. In Perl an
uninitialised value and "no value" are the same murky thing. In Raku they split
cleanly: `42` is a *defined instance* of `Int`; the bare `Int` type object is
*undefined*. `.defined` tells them apart, and an unassigned typed variable holds
the undefined type object rather than a generic `undef`:

```raku
my Int $x;
say $x.defined;       # False
say $x.WHAT;          # (Int)
```

The parentheses that `.WHAT` prints — `(Int)` — are Raku's way of showing you a
type object rather than an instance. You have been seeing them since Chapter 2.

## Definiteness: `:D` and `:U`

Because "the type" and "an instance of the type" are different values, you often
want to say *which* you will accept. That is the definiteness smiley: `:D` for a
**d**efined instance, `:U` for an **u**ndefined type object:

```raku
my Int:U $t = Int;    # a type object, fine
say $t.WHAT;          # (Int)
```

A `:D` constraint demands a real value and, tellingly, refuses to be left empty:

```raku-static
my Int:D $y;          # compile error:
                      #   Variable definition of type Int:D
                      #   needs to be given an initializer
```

The same annotation on a parameter is where you will use it most — it lets a
routine insist on a genuine object and reject a bare type by mistake, which is
covered in Chapter 15.

## The top of the hierarchy: Mu, Any, Cool

Perl has no type hierarchy to speak of. Raku's types form a tree, and it is
worth knowing the three names near the root because they explain a lot of default
behaviour. Ask any type for its method resolution order:

```raku-nobrowser
say Int.^mro;         # ((Int) (Cool) (Any) (Mu))
say Bool.^mro;        # ((Bool) (Int) (Cool) (Any) (Mu))
```

Reading right to left: **`Mu`** is the absolute root, the "most undefined"
type — its name is a nod to the Zen answer meaning "un-ask the question". Almost
nothing you write is typed as `Mu` directly. **`Any`** sits just below it and is
the *default* type of everything and the default constraint on parameters; when
you write an untyped variable, `Any` is what constrains it. **`Cool`** ("Convenient
Object-Oriented Loop", a deliberately silly acronym) is the layer that lets a
number behave like a string and vice versa — it is why `"42".succ` and `42.chars`
both work.

Because `Any` is the default, ordinary smartmatches against it succeed, while the
even-more-basic `Mu` sits outside it:

```raku-nobrowser
say 42 ~~ Any;        # True
say Mu ~~ Any;        # False
```

Two special citizens sit deliberately *off* this main line. **`Nil`** is the
absence of a value — assigning `Nil` to a typed variable resets it to its
default type object rather than storing anything:

```raku
my Int $z = 5;
$z = Nil;
say $z.raku;          # Int   — reset to the default, not undef
```

And **`Junction`** — the superposition type behind `1 | 2 | 3` — descends
straight from `Mu`, bypassing `Any` entirely:

```raku-nobrowser
my $j = 1 | 2 | 3;
say $j.WHAT;          # (Junction)
say $j.^mro;          # ((Junction) (Mu))
say 2 ~~ $j;          # True
```

That placement is not an accident: sitting below `Any` would let junctions be
caught by ordinary `Any` parameters, whereas descending from `Mu` lets them slip
*through* most routines and auto-distribute over the values inside. Junctions get
their own treatment in Chapter 27.

## Your own types: `subset`

You are not limited to the built-in types. A `subset` carves a named type out of
an existing one by attaching a `where` clause — an arbitrary predicate the value
must satisfy:

```raku-static
subset Even of Int where * %% 2;    # %% is "divisible by"
my Even $x = 4;                     # fine
my Even $y = 3;                     # Type check failed ... expected
                                    #   Even but got Int (3)
```

The `*` is the whatever-star standing in for the value under test (Chapter 17),
and `%%` is Raku's divisibility operator. A subset is a first-class type, so it
works anywhere a type does — including smartmatch, which we meet next:

```raku
subset Positive of Real where * > 0;
say  5 ~~ Positive;   # True
say -2 ~~ Positive;   # False
```

## Coercion types: `Int(Str)`

Sometimes you do not want to *reject* the wrong type but to *convert* it. A
coercion type, written `TargetType(FromType)`, accepts the source type and hands
you the target:

```raku
my Int(Str) $n = '42';
say $n.WHAT;          # (Int)
say $n;               # 42
```

The variable took a string and stored an integer. This shines in signatures —
`sub f(Int(Str) $x)` accepts a string argument and gives the body a ready-made
`Int` — and on return types, where `--> Int()` coerces the returned value
(whereas a plain `--> Int` would merely check it):

```raku-nobrowser
sub floorish(--> Int()) { 3.7 }
say floorish();       # 3
```

## Smartmatching against types

The smartmatch operator `~~`, which you have already used against subsets, works
against any type and reads like plain English — "does this value match this
type?":

```raku
say 42   ~~ Int;      # True
say 'x'  ~~ Int;      # False
say 3.14 ~~ Real;     # True
say 42   ~~ Cool;     # True
```

This is the idiomatic Raku replacement for the Perl pattern of poking at `ref()`
or `Scalar::Util::looks_like_number` — or, in modern Perl, the newer `builtin::`
helpers:

```perl
use v5.36;
use builtin qw(blessed reftype);
no warnings 'experimental::builtin';

my $obj = bless {}, 'Foo';
say blessed($obj) // 'not an object';   # Foo
say reftype($obj);                      # HASH
```

It is also the mechanism `given`/`when` uses under the hood, as Chapter 13 shows.

## `enum` and `constant`

Two smaller declarators round out the picture. An `enum` defines a set of named,
typed constants — closer to a real enumerated type than the `use constant` list
Perl programmers reach for:

```raku
enum Suit <hearts diamonds clubs spades>;
say hearts;           # hearts
say clubs.Int;        # 2      — enum values carry an ordinal
say clubs ~~ Suit;    # True   — and are a genuine type
```

Each name is a value of type `Suit`, so it can constrain a variable or a
parameter, giving you compile-checked "one of these" arguments for free. Even the
built-in `Bool` is an enum: `True.Int` is `1`.

For a single unchanging value, `constant` (met briefly in Chapter 3) needs no
sigil ceremony and works with any sigil:

```raku-nobrowser
constant PI = 3.14159;
constant @primes = 2, 3, 5, 7;
say PI;               # 3.14159
say @primes;          # (2 3 5 7)
```

## Why this matters: dispatch and signatures

Everything in this chapter converges on two features you will use constantly.
First, signatures (Chapter 15) can constrain each parameter by type, definiteness,
and even a `where` clause, so a routine documents and enforces its own contract:

```raku-static
sub factorial(Int $n where * >= 0) { [*] 1 .. $n }
say factorial(5);     # 120
say factorial(-1);    # Constraint type check failed ...
```

Second, those same type constraints let you write *several* routines of the same
name and have Raku pick the right one by the types of the arguments — multiple
dispatch, the subject of Chapter 16:

```raku
multi greet(Int $x) { "an integer: $x" }
multi greet(Str $x) { "a string: $x"  }
say greet(42);        # an integer: 42
say greet('hi');      # a string: hi
```

That is a large part of why Raku bothered to build a real type system: not to make
you annotate everything, but to let types do useful work — checking, converting,
and dispatching — precisely where you decide they should.

With variables, containers, and types behind us, Part II is complete. Next we turn
to operators, starting with the many that work exactly as you already expect.

{% include nav.html %}

---
title: Multiple Dispatch
---

{% include menu.html %}

You have written this subroutine many times. It takes an argument that might be
several different things, and its first job is to work out *which* thing, so it
can decide what to do:

```perl
use v5.10;

sub describe {
    my ($arg) = @_;
    if    (ref $arg eq 'ARRAY') { return "array of "  . scalar(@$arg) }
    elsif (ref $arg eq 'HASH')  { return "hash of "   . scalar(keys %$arg) }
    elsif (!ref $arg)           { return "scalar: $arg" }
}
say describe([1, 2, 3]);   # array of 3
say describe({a => 1});    # hash of 1
say describe(42);          # scalar: 42
```

The branching by `ref`, by `@_ == 1` versus `@_ == 2`, by whether an argument is
defined — all of it is dispatch logic done by hand. Raku pulls that logic out of
the body and into the signatures. You write one routine *per case*, mark each
with `multi`, and the compiler picks the matching one by looking at the
arguments. This is *multiple dispatch*.

## `multi`: many routines, one name

Declare more than one routine with the same name, each a `multi`, each with a
different signature. Raku chooses a *candidate* at every call:

```raku
multi greet(Str $s) { "string: $s" }
multi greet(Int $n) { "int: $n" }
say greet("hi");      # string: hi
say greet(42);        # int: 42
```

There is no `if`, no `ref`, no dispatch code you maintain. The signatures *are*
the dispatch table. Add a new case later by adding a new `multi`; nothing else
needs to change. This works for methods too — `multi method` dispatches on the
invocant's arguments in exactly the same way.

## Dispatch by arity

Candidates can differ purely in how many arguments they take. This replaces the
`@_ == 1` counting:

```raku
multi describe($a)     { "one: $a" }
multi describe($a, $b) { "two: $a, $b" }
say describe(1);      # one: 1
say describe(1, 2);   # two: 1, 2
```

Arity and type combine freely: you can have a one-argument `Int` candidate and a
two-argument `Str, Str` candidate side by side, and Raku sorts them out.

## Dispatch by type

Type-based dispatch is the direct replacement for the `ref`-testing chain we
started with. Here is that first Perl example, rebuilt:

```raku
multi describe(Array $a) { "array of {$a.elems}" }
multi describe(Hash  $h) { "hash of {$h.elems}" }
multi describe($x)       { "scalar: $x" }
say describe([1, 2, 3]);   # array of 3
say describe({a => 1});    # hash of 1
say describe(42);          # scalar: 42
```

The last candidate has no type, so it accepts anything the others turned down —
a natural catch-all.

## `proto`: one umbrella declaration

For a family of `multi`s you may want a single place that describes the shared
shape and, optionally, wraps every call. That is a `proto`:

```raku
proto process(|) {*}
multi process(Int $n) { "number $n" }
multi process(Str $s) { "text $s" }
say process(7);       # number 7
say process("x");     # text x
```

The `(|)` signature means "accept any arguments", and the `{*}` body means
"dispatch to a candidate here". You do not need a `proto` — Raku creates one
implicitly — but writing your own lets you document the group and, if you put
real code around the `{*}`, run shared logic (validation, logging) on every call.

## Narrowing with `where`

Types are not the only way to distinguish candidates. A `where` clause attaches
an arbitrary test, so you can dispatch on a *value*, not just a type. Two
candidates that differ only by a `where` are perfectly valid, and the more
specific one wins:

```raku
multi tag(Int $n)             { "any int: $n" }
multi tag(Int $n where * > 0) { "positive: $n" }
say tag(5);           # positive: 5
say tag(-3);          # any int: -3
```

The `* > 0` is a `Whatever` expression — a little anonymous test, "is it greater
than zero?" (Chapter 17 covers `*` closures in full.) A literal works as a
`where` too, which gives beautifully direct base cases:

```raku
multi fact(0)      { 1 }
multi fact(Int $n) { $n * fact($n - 1) }
say fact(5);          # 120
```

## A worked example: `fib`

The classic recursion reads almost like its mathematical definition when the base
cases become their own candidates:

```raku
multi fib(0)      { 0 }
multi fib(1)      { 1 }
multi fib(Int $n) { fib($n - 1) + fib($n - 2) }
say fib(10);          # 55
```

There is no `if $n < 2` guard inside the body; the guards *are* the two literal
candidates. The recursive case never sees `0` or `1`, because a more specific
candidate always claims them first.

## Definiteness: `:D` and `:U`

Raku can dispatch on whether an argument is a *defined value* or an *undefined
type object* — the distinction between `42` and the bare type `Int`. Append `:D`
(defined) or `:U` (undefined) to a type:

```raku
multi handle(Int:D $n) { "defined int $n" }
multi handle(Int:U $t) { "undefined int of type {$t.^name}" }
say handle(5);        # defined int 5
say handle(Int);      # undefined int of type Int
```

This is the clean way to say "give me a real number here, not an uninitialised
one" — a check that in Perl you would write as `defined $n or die`.

## `is default` for ties

When two candidates are equally good matches, you can nominate one as the
tie-breaker with `is default`:

```raku
multi pick(Int $n)      { "int $n" }
multi pick($x) is default { "other $x" }
say pick(3);          # int 3
say pick("q");        # other q
```

## How the winner is chosen

The rule is: **the most specific matching candidate wins.** A candidate that
constrains more — a narrower type, an added `where`, a definiteness marker —
beats a looser one. `Int` beats the untyped `$x`; `Int where * > 0` beats plain
`Int`; a literal `0` beats `Int`.

If two candidates are equally specific and neither is `is default`, Raku refuses
to guess. It raises an ambiguity error rather than pick arbitrarily:

```raku-nobrowser
multi f(Int $a, $b) { "a" }
multi f($a, Int $b) { "b" }
say (try f(1, 2)) // "ambiguous dispatch";   # ambiguous dispatch
```

Here `f(1, 2)` matches both — the first argument fits candidate one's `Int`, the
second fits candidate two's `Int` — and neither is more specific overall. The
fix is to add a candidate that resolves the overlap, or to mark one `is default`.

## Putting it together

A small geometry example shows how naturally this scales. Each shape is a class
(Chapter 22 covers classes properly), and each gets its own `area` candidate:

```raku
class Circle    { has $.r }
class Rectangle { has $.w; has $.h }

multi area(Circle $c)    { pi * $c.r ** 2 }
multi area(Rectangle $r) { $r.w * $r.h }

say area(Circle.new(r => 2)).round(0.01);   # 12.57
say area(Rectangle.new(w => 3, h => 4));    # 12
```

Adding a `Triangle` later means adding one `multi area(Triangle $t)` — and no
existing code is touched. That open-ended extensibility is the real payoff:
where Perl's `if`/`elsif` chain is a closed structure you must edit, a set of
`multi`s is an open one you extend.

Dispatch decides *which* block of code runs. The next chapter looks at blocks
themselves — how Raku turns anonymous subs, closures, and the humble `{ ... }`
into first-class, composable values.

{% include nav.html %}

---
title: New Operators and Meta-operators
---

{% include menu.html %}

This is the chapter with no Perl equivalents. Everything so far had a
counterpart you could point to; here Raku gives you operators that fold entire
loops — sum this, pair those, compare all of these — into a single expression.
Some are ordinary operators with new jobs; the more powerful ones are
*meta-operators*: little modifiers that take an operator you already know and
build a new one out of it. Learn the handful of meta-operators and you get a
combinatorial number of operators for free.

Throughout, each example is paired with the Perl loop it replaces.

## The equality family

Perl has `==` and `eq` and, for references, the fact that two references are
equal only if they point to the same thing. Raku teases apart four distinct
questions that all hid behind that, and gives each its own operator.

`eqv` asks whether two things are *structurally equivalent* — same type, same
contents, all the way down. It is what you actually wanted whenever you reached
for a deep-comparison module:

```perl
# Perl: needs a module for a deep compare
use Test::More;
is_deeply([1, 2, 3], [1, 2, 3]);   # pass
```

```raku
say [1, 2, 3] eqv [1, 2, 3];       # True
say (1, 2, 3) eqv (1, 2, 3);       # True
```

`===` asks whether two things are *the same value* (value identity). Two
immutable values like `42` or `"abc"` are always the same value; two freshly
built arrays are not, even if their contents match:

```raku
say 42 === 42;             # True
say "abc" === "abc";       # True
say [1, 2] === [1, 2];     # False   (two distinct arrays)
```

`=:=` asks the strictest question of all: do two names refer to *the very same
container*? This is the closest thing to Perl's "same reference" test, but at
the level of the variable's storage box (see Chapter 8 on containers):

```raku-nobrowser
my $x = 5;
my $y = 5;
say $x =:= $y;             # False  (different containers)
my $z := $x;               # bind: $z is an alias for $x
say $z =:= $x;             # True   (same container)
```

Finally `=~=` is *approximate* equality — a godsend for floating-point work,
where exact `==` is a trap. It treats two numbers as equal if they are within a
tiny relative tolerance:

```raku
say sqrt(2) ** 2 == 2;     # False   (it is 2.0000000000000004)
say sqrt(2) ** 2 =~= 2;    # True
say 0.1 + 0.2 =~= 0.3;     # True
```

## The reduction meta-operator: `[ ]`

Wrap any infix operator in square brackets and it becomes a *reduction* — it
inserts that operator between all the elements of a list. This single
meta-operator replaces a whole category of accumulator loops.

The classic sum. In Perl you write the loop (or reach for `List::Util`):

```perl
use List::Util 'sum';
my @a = (1, 2, 3, 4, 5);
my $total = 0;
$total += $_ for @a;      # 15
```

```raku
my @a = 1, 2, 3, 4, 5;
say [+] @a;               # 15
```

The same trick works for any operator, which is the point — you are not learning
`sum`, `product`, `max`, and `join` as separate functions, you are applying one
idea:

```raku
say [*] 1..5;             # 120   (factorial of 5)
say [max] 3, 1, 4, 1, 5;  # 5
say [~] <a b c>;          # abc   (like join with no separator)
```

Reduce with a comparison and you get a chained comparison over a whole list —
"is this list strictly ascending?" collapses to five characters:

```raku
say [<] 1, 2, 3;          # True
say [<] 1, 3, 2;          # False
```

A reduction over an empty list returns the operator's identity value, so `[+] ()`
is `0` and `[*] ()` is `1` — no special-casing required.

## Hyper operators: `»` and `«`

A hyper operator applies an ordinary operator to *every element* of a list at
once — a `map` without the ceremony. The pointy quotes aim at the list side (or
sides). To add one to every element:

```perl
my @a = (1, 2, 3);
my @b = map { $_ + 1 } @a;   # (2, 3, 4)
```

```raku
my @a = 1, 2, 3;
say @a »+» 1;                # [2 3 4]
```

Point quotes on *both* sides and Raku zips two lists together element-by-element:

```perl
my @x = (1, 2, 3);
my @y = (10, 20, 30);
my @sum;
$sum[$_] = $x[$_] + $y[$_] for 0 .. $#x;   # (11, 22, 33)
```

```raku
say (1, 2, 3) »+« (10, 20, 30);            # (11 22 33)
```

The same idea works for *method calls* — `».method` runs the method on every
element and collects the results:

```raku
say <hello world>».tc;       # (Hello World)
say (-1, -2, 3)».abs;        # (1 2 3)
```

Besides being concise, hyper operations are explicitly parallelisable: you are
promising Raku the elements do not depend on one another, which is why the
brackets point outward like arrows.

## The cross operator: `X`

`X` produces the *cross product* of two or more lists — every combination, in
order. In Perl that is a nested loop:

```perl
my @pairs;
for my $l ('a', 'b') {
    for my $n (1, 2) {
        push @pairs, "$l$n";
    }
}
# a1 a2 b1 b2
```

```raku
say <a b> X <1 2>;           # ((a 1) (a 2) (b 1) (b 2))
```

By itself `X` pairs the elements up. Glue an operator onto it — `Xoperator` — and
it *combines* each pair with that operator instead. `X~` concatenates, `X*`
multiplies:

```raku
say <a b> X~ <1 2>;          # (a1 a2 b1 b2)
say (1..3) X* (1..3);        # (1 2 3 2 4 6 3 6 9)  — a times table
```

That last line is a complete multiplication table as one expression.

## The zip operator: `Z`

Where `X` takes *every* combination, `Z` takes them *in lockstep* — first with
first, second with second — stopping when the shortest list runs out. It is the
tool for walking two parallel arrays:

```perl
my @names = ('Alice', 'Bob');
my @ages  = (30, 25);
for my $i (0 .. $#names) {
    say "$names[$i] is $ages[$i]";
}
```

```raku
say <a b c> Z <1 2 3>;       # ((a 1) (b 2) (c 3))
```

Like `X`, `Z` takes an operator suffix. `Z+` adds paired elements; a `Z*`
followed by a `[+]` reduction is the whole of a dot product:

```raku
my @prices = 10, 20, 30;
my @qty    = 2, 1, 5;
say [+] @prices Z* @qty;     # 190
```

## The sequence operator: `...`

The sequence operator builds a list by working out the pattern from the elements
you give it and continuing until an endpoint. Give it two or three terms and it
infers an arithmetic or geometric step:

```raku
say (1, 2, 4 ... 256);       # (1 2 4 8 16 32 64 128 256)
say (1 ... 5);               # (1 2 3 4 5)
say ('a' ... 'e');           # (a b c d e)
```

Its real power is a *generator*: give it a closure that computes the next term
from previous ones, and a `*` (the Whatever star, below) as the endpoint to mean
"go forever". The Fibonacci sequence, famously, is a one-liner — each term is the
sum of the previous two:

```raku
say (1, 1, * + * ... *)[^10];   # (1 1 2 3 5 8 13 21 34 55)
```

Because the list is lazy it can be infinite; here `[^10]` simply takes the first
ten. This replaces the hand-written state-carrying loop you would write in
Perl to generate such a series.

## Feed operators: `==>` and `<==`

Feed operators pass a list from one processing stage to the next, so a pipeline
reads in the order the data actually flows — the shell-pipe idea, but native. The
rightward feed `==>` sends its left side into the *last* argument of its right
side:

```perl
my @result;
for (1 .. 10) {
    next unless $_ % 2 == 0;
    push @result, $_ ** 2;
}
# 4 16 36 64 100
```

```raku
1..10 ==> grep(* %% 2) ==> map(* ** 2) ==> my @result;
say @result;                 # [4 16 36 64 100]
```

Read that left to right: take `1..10`, keep the even ones, square them, land the
lot in `@result`. The leftward `<==` does the same in the opposite direction, so
the destination comes first:

```raku
my @result;
@result <== map(* ** 2) <== grep(* %% 2) <== 1..10;
say @result;                 # [4 16 36 64 100]
```

**A gotcha worth its own paragraph.** The natural-looking `my @result = 1..10
==> grep(...)` does *not* work, because `==>` binds looser than `=`: Raku assigns
`1..10` to `@result` first and then feeds that away into nothing. Put the
destination at the *end* of a rightward feed (`... ==> my @result`), or use the
leftward `<==` form. This trips up almost everyone the first time.

## The Whatever star: `*` and `WhateverCode`

You have seen `*` appearing in the examples above. On its own, in a context that
wants a value, `*` is the *Whatever* — a placeholder meaning "everything" or "the
obvious thing" (as in `@a[*]` for all elements, or `...*` for "no end"). But the
moment you use `*` inside an *expression*, something clever happens: Raku turns
the surrounding expression into a small anonymous function, a `WhateverCode`,
with the `*` as its argument.

So `* + 1` is not a value — it is a function that adds one to whatever you give
it. This is the terse closure you will use constantly with `map`, `grep`, and
`sort`:

```perl
my @plus = map { $_ + 1 } (1, 2, 3);          # (2, 3, 4)
my @big  = grep { $_ > 2 } (1, 2, 3, 4);      # (3, 4)
```

```raku
say (1, 2, 3).map(* + 1);                  # (2 3 4)
say (1..4).grep(* > 2);                    # (3 4)
say <banana apple cherry>.sort(*.chars);   # (apple banana cherry)
```

Each `*` becomes a parameter, in order, so `* + *` is a two-argument function —
which is exactly what fed the Fibonacci sequence above. When one `*` is not
enough or the logic gets involved, fall back to an explicit block or pointy
block; Chapter 17 covers the full range of block and closure forms.

## Negated and reversed meta-operators

Two more meta-operators round things out, each transforming an operator you
already have.

The *negation* meta-operator puts `!` in front of any comparison operator to
invert its result. You know `!=` (that is really `!` applied to `==`); the same
trick works on *any* comparison, including the word-named ones and the new ones:

```raku
say 5 != 6;                # True
say 'a' !eq 'b';           # True   (negated eq)
say [1, 2] !eqv [1, 3];    # True   (negated eqv)
```

The *reverse* meta-operator, `R`, swaps an operator's two operands. `R-` is
"subtract, backwards", `R/` is "divide, the other way round" — handy when the
argument order an API hands you is the reverse of what you want:

```raku
say 10 R- 3;               # -7   (computes 3 - 10)
say 2 R/ 10;               # 5    (computes 10 / 2)
say [R~] <a b c>;          # cba  (reduce, concatenating right-to-left)
```

Meta-operators compose, which is where the real economy lies: `[R-]` above is the
reduction meta-operator wrapping the reversed subtraction operator. One surprise
to note — reversing also makes the operator right-associative, so `[R-] 1, 2, 3`
becomes `1 R- (2 R- 3)`, which works out to `1 R- 1`, and finally to `0`. When a
meta-operator does something unexpected, expanding it by hand like this is the
quickest way to see why.

That completes the operator tour. You now have the vocabulary — the familiar
operators of Chapter 10 and the meta-operators here — to write expressions that,
in Perl, would have been loops. Next we put those expressions to work inside
Raku's control flow, starting with conditionals and loops in Chapter 12.

{% include nav.html %}

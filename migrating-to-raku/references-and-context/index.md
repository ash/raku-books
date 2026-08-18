---
title: References, Containers, and Context
---

{% include menu.html %}

If one chapter in this book is going to make you pause, it may be this one. Not
because Raku made things harder here, but because it quietly retired two of the
concepts you lean on most in Perl: the *reference* and the notion of *context*
as a global, invisible force. Both are still present in spirit, but they have
been replaced by something more explicit — the *container* — and by rules that
are decided locally rather than guessed at a distance.

The good news is that most of the time you write *less* punctuation, not more.
The arrows go away. This chapter explains what took their place.

## Why the backslash mostly disappears

In Perl, you cannot put an array inside a scalar. You put a *reference* to it,
and you dereference it — with a backslash going in and an arrow coming out:

```perl
my @a = (1, 2, 3);
my $ref = \@a;
say $ref->[0];        # 1
say scalar @$ref;     # 3
say $$ref[1];         # 2
```

That machinery — `\`, `->`, `@$`, `$$` — is the connective tissue of every
non-trivial Perl data structure. In Raku almost all of it is gone. You assign
the array straight into the scalar, no backslash, and you index it with no arrow:

```raku
my @a = 1, 2, 3;
my $ref = @a;         # no backslash
say $ref[0];          # 1
say $ref.elems;       # 3
say $ref.WHAT;        # (Array)
```

Ask `$ref` what it holds and it says `(Array)` — an actual array, living happily
inside a scalar. The reason you no longer need `\` is that a Raku scalar was
*already* a reference-like thing all along. To see why, we have to name the box.

## The Scalar container

In Chapter 3 we called a variable a "box holding a value". That box has a type,
and its name is `Scalar`. Every `$` variable is a `Scalar` container, and the
value lives *inside* it:

```raku
my $x = 42;
say $x.VAR.WHAT;      # (Scalar)
```

`.VAR` asks for the container rather than the value; `.WHAT` on it confirms the
box is a `Scalar`. This is the object that Perl's references were reaching for
without a name. Because a `$` variable is inherently a container, you can store
anything in it — including an `Array` or a `Hash` — and reach inside without an
arrow:

```raku
my $arr  = [1, 2, 3];
my $hash = {a => 1, b => 2};
say $arr[0];          # 1
say $hash<a>;         # 1
say $arr.elems;       # 3
```

Compare that with Perl's `$arr->[0]` and `$hash->{a}`. The arrow is redundant
in Raku because there is nothing to dereference: the sigil already told the
compiler this is one item, and `[…]` or `{…}` says you want to look inside it.

## Assignment, binding, and the container

Chapter 3 introduced binding with `:=`. Now that we have a name for the box, the
distinction is sharp. **Assignment (`=`) puts a value into the container.
Binding (`:=`) replaces the container itself** — it makes a name an alias for
another box, or ties it directly to a value with no box at all:

```raku
my $a = 5;
my $b := $a;          # $b and $a are now the same container
$b = 99;
say $a;               # 99
```

Bind to a bare value and there is no container to assign into, so the name
becomes read-only:

```raku-static
my $c := 10;
$c = 20;              # Cannot assign to an immutable value
```

This is not a party trick. It is exactly how a signature ties a parameter to its
argument (Chapter 15), and it is why arguments are read-only by default.

## The backslash that remains: Capture

Raku does keep `\`, but it means something new: it builds a `Capture` — a frozen
bundle of positional and named arguments, the raw material of every subroutine
call:

```raku
my $c = \(1, 2, foo => 3);
say $c.WHAT;          # (Capture)
say $c.list;          # (1 2)
say $c.hash;          # Map.new((foo => 3))
```

You will rarely construct one by hand, but recognising `\(…)` as "a captured
argument list" saves confusion when you meet it in Chapter 15.

## Itemisation: treating a list as one thing

Here is the first behaviour that catches Perl programmers out. In Perl a list
in list context flattens; you expect `(@a, @b)` to spill into one long list. In
Raku it does not:

```raku
my @a = 1, 2, 3;
say (@a, @a).elems;   # 2   — two arrays, not six numbers
```

Each `@a` counts as a *single item*. A `@` variable is already "itemised": it
puts itself into a surrounding list as one element, not as its contents. This is
the same principle as the invariant sigil — the array is one thing until you
explicitly ask otherwise.

When you *want* a list to behave as a single item, you itemise it deliberately
with `$(…)` or the `.item` method. The clearest demonstration is a `for` loop,
which normally iterates a list element by element:

```raku
for (1, 2, 3) { .say }    # three lines: 1, 2, 3
for $(1, 2, 3) { .say }   # one line:  (1 2 3)
```

`$(…)` wrapped the list into a single scalar item, so the loop ran once. Reading
a `$` sigil as "one thing, whatever its shape" makes this consistent rather than
surprising.

## Flattening and the Slip

If itemisation makes many into one, *flattening* makes one into many. When you do
want an array's elements to spill into a surrounding list, prefix it with `|`,
which produces a `Slip` — a list that dissolves into its context:

```raku
my @a = 1, 2, 3;
my @b = 0,  @a, 4;    # [0 [1 2 3] 4]   — @a stays nested
my @c = 0, |@a, 4;    # [0 1 2 3 4]     — |@a flattens in
say @b.elems;         # 3
say @c.elems;         # 5
say (|@a, |@a).elems; # 6
```

A `Slip` is a real type — `slip(1, 2, 3).WHAT` is `(Slip)` — and the `|` prefix
and the `.flat` method are the everyday ways to make one:

```raku
say ((1, 2), (3, 4)).flat;   # (1 2 3 4)
```

The other side of the coin is `Empty`, the slip of nothing. Dropping it into a
list contributes zero elements — a tidy way to conditionally omit a value:

```raku
my @d = 1, Empty, 2;
say @d;               # [1 2]
say @d.elems;         # 2
```

## `@a` versus `@a[]` versus `$@a`

Three forms that look alike but signal intent:

```raku
my @a = 1, 2, 3;
say @a.WHAT;          # (Array)
say @a[].WHAT;        # (Array)   — the empty slice, all elements
say $@a.WHAT;         # (Array)
```

They report the same type, but they differ in how they *behave in a list*.
Plain `@a` is the array. `@a[]` is the "zen slice" — every element, useful mostly
inside string interpolation where a bare `@a` will not interpolate:

```raku
my @a = 1, 2, 3;
say "list: @a[]";     # list: 1 2 3
```

And `$@a` itemises the array, the scalar-sigil equivalent of `@a.item` — it packs
the array so it counts as one element in an enclosing list. Reach for it only
when you specifically need that packing.

## Context: decided locally, not guessed

Perl's context is a property of the *place* an expression sits. The same
subroutine returns different things depending on whether it was called in scalar
or list context, and it inspects that context with `wantarray`:

```perl
sub ctx { return wantarray ? 'list' : 'scalar' }
my @x = ctx();        # list
my $y = ctx();        # scalar
```

Raku has no `wantarray`, and a routine does not change what it returns based on
where it was called. It returns one value; the *receiving* side decides the
shape, driven by the sigil of the variable and the signatures involved:

```raku
sub items { 1, 2, 3 }
my @x = items();      # 3 elements
my $y = items();      # one List
say @x.elems;         # 3
say $y.WHAT;          # (List)
say $y.elems;         # 3
```

The routine ran identically both times. `@x` unpacked the returned list into an
array; `$y` kept it whole as a single `List`. Nothing was guessed at a distance.

Where Perl used scalar context to *count*, Raku is explicit. Numeric context is
the `+` prefix, and there is always `.elems`:

```raku
my @a = 10, 20, 30;
say +@a;              # 3
say @a.elems;         # 3
```

## Decontainerisation

Occasionally a value arrives wrapped in a container you want to peel away. The
postfix `<>` operator (or `.list` / `@$x`) decontainerises. The clearest case is
iterating an array held in a scalar: because the scalar is one item, `for` treats
it as one:

```raku
my @a = 1, 2, 3;
my $x = @a;
for $x  { .say }      # one iteration: [1 2 3]
for @$x { .say }      # three iterations: 1, 2, 3
```

`@$x` (short for `@($x)`) says "look at the value inside `$x` as a list", the
Perl `@$ref` idiom surviving almost verbatim.

## Sink context

One last context worth naming. When an expression's value is not used at all — a
statement evaluated purely for its position — it is in *sink* context, Raku's word
for what Perl would call void context. Raku actively warns when you compute
something and then throw it away:

```raku-static
my @a = 1, 2, 3;
@a;                   # WARNING: Useless use of @a in sink context
```

That warning has caught many a real bug where a programmer meant to *do*
something with a value and forgot. If a loop or a lazy sequence needs to run for
its side effects, calling it in sink context is exactly right; the warning only
fires for values that are plainly inert.

References gave way to containers; context moved from a guess to a rule. The
other place Raku made the implicit explicit is the type of a value — which is
where we turn next.

{% include nav.html %}

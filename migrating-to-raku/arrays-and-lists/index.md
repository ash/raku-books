---
title: Arrays and Lists
---

{% include menu.html %}

In Perl there is one flat idea of a list and one kind of array, and the two
blur together constantly: a list in list context spills its elements into
whatever surrounds it. Raku keeps arrays and lists close but draws one sharp new
line between them — a `List` is *immutable*, an `Array` is *mutable* — and it
stops flattening things behind your back. Those two changes explain most of what
feels different here, so let us take them in order.

## `List` versus `Array`

In Perl, parentheses and square brackets do quite different jobs: `(1, 2, 3)`
is a list, `[1, 2, 3]` is an anonymous array *reference*. Raku keeps both
literals, and the distinction is now about mutability rather than references.

Round brackets build an immutable `List`. Square brackets build a mutable
`Array`:

```raku
say (1, 2, 3).WHAT;      # (List)
say [1, 2, 3].WHAT;      # (Array)
```

You cannot assign to an element of a `List` — it is read-only:

```raku-static
my $list = (1, 2, 3);
$list[0] = 99;           # dies: Cannot modify an immutable Int (X::Assignment::RO)
```

An `Array`, whether written with `[…]` or held in a `@` variable, is mutable in
the way you expect:

```raku
my @a = 1, 2, 3;
@a[0] = 99;
say @a;                  # [99 2 3]
```

Note that the right-hand side needs no parentheses: `my @a = 1, 2, 3;` is the
idiomatic form. The commas build a list, and assigning it to a `@` variable
copies the elements into a fresh, mutable array.

## Indexing keeps the sigil

Chapter 2 introduced the headline rule and it is worth seeing it in full here. In
Perl you switch the sigil to `$` to reach one element; in Raku the sigil stays
`@`, and the brackets alone say "one element":

```perl
my @a = (10, 20, 30, 40, 50);
say $a[0];               # 10   — sigil switched to $
say $a[-1];              # 50   — negative index
```

```raku
my @a = 10, 20, 30, 40, 50;
say @a[0];               # 10   — sigil stays @
say @a[*-1];             # 50   — the last element
```

Negative indices are the one habit to unlearn. In Raku, `@a[-1]` is an error;
you write `@a[*-1]`, where `*` stands for "the number of elements" and `*-1` is
therefore "one before the end". It reads oddly at first, but it composes:
`@a[*-2]` is the second-to-last, and so on.

```raku-static
say @a[*-2];             # 40
```

## Slices

A slice pulls several elements at once. Give the subscript a list of indices, or
a range:

```raku
my @a = 10, 20, 30, 40, 50;
say @a[1, 2, 3];         # (20 30 40)
say @a[1..3];            # (20 30 40)
```

This is exactly Perl's `@a[1, 2, 3]`, except that — you guessed it — the sigil
no longer changes from `@` to anything else, because a slice is already a `@`
thing. The result is a `List` of the selected elements.

## Adding and removing elements

The familiar quartet — `push`, `pop`, `shift`, `unshift` — plus `splice` are all
present. The novelty is that each one is available both as a function and as a
method, and the method form reads left to right:

```perl
my @a = (1, 2, 3);
push @a, 4;
my $last = pop @a;
```

```raku
my @a = 1, 2, 3;
@a.push(4);              # method form
push @a, 5;              # function form — same effect
say @a;                  # [1 2 3 4 5]
say @a.pop;              # 5
say @a.shift;            # 1
@a.unshift(0);
say @a;                  # [0 2 3 4]
```

`splice` behaves as before — remove a run of elements, optionally inserting
others in their place — and returns what it removed:

```raku
my @s = 1..10;
say @s.splice(2, 3);     # [3 4 5]   — the removed elements, as an Array
say @s;                  # [1 2 6 7 8 9 10]
@s.splice(1, 0, 'x', 'y');
say @s;                  # [1 x y 2 6 7 8 9 10]
```

## The big flattening change

This is the difference most likely to catch a Perl programmer out. In Perl,
lists flatten automatically and deeply: put an array inside another list and its
elements dissolve into the surrounding one.

```perl
my @a = (1, 2, 3);
my @b = (4, 5, 6);
my @nested = (@a, @b);
say scalar @nested;      # 6      — flattened to one long list
```

Raku does *not* do this. An array assigned inside another array stays a single
element:

```raku
my @a = 1, 2, 3;
my @b = 4, 5, 6;
my @nested = @a, @b;
say @nested.elems;       # 2
say @nested;             # [[1 2 3] [4 5 6]]
say @nested[0];          # [1 2 3]
```

This is a deliberate change. Perl's automatic flattening is convenient until
the day it silently destroys the structure you meant to keep — passing an array
and a hash to a subroutine and watching them merge into one list. Raku preserves
structure by default and asks you to flatten *explicitly*.

When you do want the old behaviour, you have three tools. The `.flat` method
flattens a structure one level:

```raku-static
say (@a, @b).flat.elems;     # 6
```

The `|` prefix (the *slip* operator) flattens a single item into the list it
sits in:

```raku-static
my @flat = 1, |@a, 5;
say @flat;                   # [1 1 2 3 5]
```

And `Slip` is the underlying type — a list that, unlike an ordinary array,
flattens into its surroundings even through a scalar:

```raku
my $sl = slip(4, 5);
my @b = 1, $sl, 6;
say @b;                      # [1 4 5 6]
```

Contrast that with an ordinary array held in a scalar, which stays put:

```raku
my @a = 1, 2, 3;
my @b = 1, @a, 5;
say @b.elems;                # 3
say @b;                      # [1 [1 2 3] 5]
```

If you learn one new reflex in this chapter, make it this: **arrays no longer
flatten themselves — reach for `.flat` or `|` when you need it.**

## Inspecting and reordering

`elems` gives the length; `end` gives the index of the last element (one less
than `elems`):

```raku
my @a = 10, 20, 30, 40, 50;
say @a.elems;            # 5
say @a.end;              # 4
say @a.reverse;          # (50 40 30 20 10)
```

`sort` deserves special attention, because its default changed for the better.
Perl's `sort` compares as *strings* unless you supply a block, which is why
numbers come out in the wrong order:

```perl
my @n = (3, 11, 2, 100, 1);
say join ',', sort @n;   # 1,100,11,2,3   — string order!
```

Raku's default `sort` uses `cmp`, which compares numbers numerically and strings
alphabetically, so numbers just sort as numbers:

```raku
my @n = 3, 11, 2, 100, 1;
say @n.sort;             # (1 2 3 11 100)
```

For a custom order, pass a block. Note the colon: `sort:` takes the block as its
argument. Here the placeholder parameters `$^a` and `$^b` (Chapter 17) give a
descending sort:

```raku-static
say @n.sort: { $^b <=> $^a };    # (100 11 3 2 1)
```

## The list toolkit

The workhorses you know from Perl are all methods now, and they chain. Most
take a block, or the `*` "whatever" shorthand for a one-argument block:

```raku
my @n = 3, 11, 2, 100, 1;
say @n.grep(* > 3);      # (11 100)
say @n.map(* * 2);       # (6 22 4 200 2)
say @n.first(* > 10);    # 11
say @n.sum;              # 117
say @n.min;              # 1
say @n.max;              # 100
say @n.join(', ');       # 3, 11, 2, 100, 1
```

`grep` and `map` no longer return a plain list, though — they return a `Seq`,
which brings us to laziness.

## `Seq` and laziness

A `Seq` is a sequence that is computed on demand and can be consumed once. Many
Raku operations produce one, and ranges are lazy too, so you can describe an
infinite list without hanging your program:

```raku
say (1..5).map(* * 2).WHAT;      # (Seq)
say (1..Inf).WHAT;               # (Range)
```

`1..Inf` is a perfectly good value; nothing is computed until you ask for
elements. Take the first few with `.head`, the last few with `.tail`, or slice
with a range subscript:

```raku
say (1..Inf).head(3);            # (1 2 3)
say (1..10).tail(3);             # (8 9 10)
my @squares = (1..Inf).map(* ** 2);
say @squares[^5];                # (1 4 9 16 25)
```

That `^5` is the range `0..^5` — `0, 1, 2, 3, 4` — a compact way to take the
first five. Laziness means the mapping over an infinite range only ever computes
the five squares you actually read. Chapter 27 returns to lazy lists and
`gather`/`take` in earnest.

## A `@` variable versus a scalar holding an array

One last contrast to file away. In Perl you distinguish an array from a
reference to it with a backslash: `my $ref = \@a`. In Raku, assigning an array to
a scalar simply stores the array itself as a single item — no backslash, and it
dereferences without an arrow:

```raku
my @a = 1, 2, 3;
my $ref = @a;
say $ref.WHAT;           # (Array)
say $ref.elems;          # 3
say $ref[0];             # 1
```

The `@` sigil promises "these elements flatten and iterate as a list"; a scalar
holds the array as *one* opaque item that stays intact in a surrounding list —
which is why `1, $ref, 5` had three elements above. Containers, itemisation, and
how `$`, `@`, and `%` relate get their full account in Chapter 8; for now,
remember that putting an array in a `$` is Raku's gentle equivalent of taking a
reference.

With ordered collections in hand, we turn to the other great data structure —
the hash — where the keys, not the positions, do the indexing.

{% include nav.html %}

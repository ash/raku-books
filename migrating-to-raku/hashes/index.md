---
title: Hashes
---

{% include menu.html %}

Hashes survive the move to Raku almost intact: they are still unordered
collections of key–value pairs, still declared with `%`, still the natural way to
count things and look things up. The changes are small but constant — the sigil
stays `%` when you index, angle brackets give you a shorthand for string keys,
and the pair itself is promoted to a first-class object. And at the end of the
chapter we meet three immutable cousins — `Set`, `Bag`, and `Mix` — that Perl
never had.

## Subscripting: `{…}` and `<…>`

In Perl you switch the sigil to `$` and use braces, quoting or barewording the
key:

```perl
my %ages = (Alice => 30, Bob => 25);
say $ages{Alice};        # 30   — bareword key
my $name = 'Bob';
say $ages{$name};        # 25   — key from a variable
```

In Raku the sigil stays `%`, and there are two bracket styles. Braces `{…}` take
an arbitrary expression as the key — a variable, a computation, anything:

```raku
my %ages = Alice => 30, Bob => 25;
my $name = 'Bob';
say %ages{$name};        # 25
say %ages{'Alice'};      # 30
```

Angle brackets `<…>` are the shorthand for a *constant* string key. They quote
for you, just like Perl's `qw//`, so there are no quotes and no comma:

```raku-static
say %ages<Alice>;        # 30
```

The rule of thumb: use `<…>` for literal keys you type in the source, and `{…}`
when the key comes from a variable or expression. It is the exact analogue of the
array split between `@a[…]` for computed indices and the constant case.

## Building hashes

The fat arrow `=>` works as before, and — a nice bonus — it also auto-quotes the
word on its left, so you rarely need quotes around keys:

```raku-static
my %ages = Alice => 30, Bob => 25;
```

You can be explicit with the `%()` hash constructor, useful when you want a hash
literal in the middle of an expression:

```raku
my %h = %(one => 1, two => 2);
say %h;                  # {one => 1, two => 2}
```

And you can still build a hash from a flat list of alternating keys and values,
exactly as in Perl:

```raku
my %from = <a 1 b 2 c 3>;
say %from.elems;         # 3
```

## Keys are unordered, and `Pair` is an object

As in Perl, a hash has no inherent order — do not rely on the sequence in which
keys come back. What is new is that each key–value coupling is a real object, a
`Pair`, which you can create and pass around on its own:

```raku
my $p = 'x' => 10;
say $p.WHAT;             # (Pair)
say $p.key;              # x
say $p.value;            # 10
```

A hash, then, is essentially a collection of `Pair`s, and much of the iteration
vocabulary below hands them back to you.

## Iterating

The familiar `keys` and `values` return lists (here sorted for a stable display):

```raku
my %h = apple => 3, banana => 5, cherry => 2;
say %h.keys.sort;        # (apple banana cherry)
say %h.values.sort;      # (2 3 5)
```

The idiomatic way to walk a whole hash is `kv`, which yields keys and values
alternately, unpacked into two loop variables by a pointy block:

```raku-static
for %h.kv -> $k, $v {
    say "$k: $v";
}
```

```
apple: 3
cherry: 2
banana: 5
```

Alternatively, `pairs` gives you `Pair` objects directly, which you can sort and
print whole:

```raku-static
for %h.pairs.sort -> $pair {
    say $pair;           # e.g. apple => 3
}
```

## Existence, deletion, and slicing by adverb

Perl uses the functions `exists` and `delete`:

```perl
my %h = (apple => 3, banana => 5);
say exists $h{apple};    # 1
delete $h{apple};
```

Raku turns these into *adverbs* on the subscript — a colon-word suffix that
modifies what the subscript returns. `:exists` and `:delete` do what their names
say, and `:delete` returns the value it removed:

```raku
my %h = apple => 3, banana => 5, cherry => 2;
say %h<apple>:exists;    # True
say %h<grape>:exists;    # False
say %h<apple>:delete;    # 3     — and apple is now gone
say %h.keys.sort;        # (banana cherry)
```

Two more adverbs round out the family: `:v` returns the value (the default
behaviour of a subscript), and `:k` returns the key when it exists:

```raku-static
say %h<banana>:v;        # 5
say %h<banana>:k;        # banana
```

The adverb syntax composes with slices too, so `%h<a b c>:delete` removes and
returns several entries at once — a tidy replacement for a hand-written loop.

## Defaults and autovivification

Autovivification works as in Perl: reaching into a nested key springs the
intermediate hashes into being:

```raku
my %tree;
%tree<a><b><c> = 1;
say %tree;               # {a => {b => {c => 1}}}
```

The classic counting idiom needs nothing special — a missing key reads as
undefined, and `++` treats that as zero:

```raku
my %count;
%count{$_}++ for <a b a c a>;
say %count.sort;         # (a => 3 b => 1 c => 1)
```

If you want a missing key to read as some other value, declare the hash with `is
default`:

```raku
my %h is default(0);
say %h<missing>;         # 0
```

## Typed hashes

Raku lets you constrain a hash's keys to a particular type by naming it in braces
after the variable — a guarantee Perl could not make. `my %h{Str}` is the
default (string keys); more interesting is constraining to another type:

```raku
my %scores{Str};
say %scores.WHAT;        # (Hash[Any,Str])

my %byint{Int};
%byint{1} = 'one';
say %byint{1};           # one
```

Feed such a hash a key of the wrong type and you get a type-check error at the
point of use, rather than a silent stringification — one more class of bug caught
early.

## Set, Bag, and Mix: the hash-like cousins

Perl programmers routinely fake a set with a hash whose values are all `1`.
Raku gives you the real thing. A `Set` is an immutable, unordered collection of
distinct elements; a `Bag` adds integer counts (a multiset); a `Mix` allows
fractional weights.

```raku
my $s = <apple banana cherry>.Set;
say $s.WHAT;             # (Set)

my $bag = <a a b c c c>.Bag;
say $bag<c>;             # 3     — how many c's
say $bag<a>;             # 2

my $m = (apple => 0.5, banana => 2.5).Mix;
say $m<banana>;          # 2.5
```

The payoff is a set of operators that read like mathematics. Membership is `∈`
(or the ASCII `(elem)`); union is `∪` (`(|)`), intersection is `∩` (`(&)`):

```raku-static
my $a = <a b c>.Set;
my $b = <b c d>.Set;
say 'apple' ∈ $s;        # True
say $a ∪ $b;             # Set(a b c d)
say $a ∩ $b;             # Set(b c)
say $a (|) $b;           # Set(a b c d)   — ASCII form
say $a (&) $b;           # Set(b c)
```

These types are immutable, so they suit exactly the jobs where a hash-as-set was
always a slightly awkward fit: deduplication, membership tests, counting
occurrences, and set arithmetic without a single manual loop.

Hashes and their cousins map keys to values; next we look more closely at the
values themselves, starting with Raku's numeric tower in Chapter 6.

{% include nav.html %}

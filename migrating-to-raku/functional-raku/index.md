---
title: Functional Raku
---

{% include menu.html %}

You have been writing functional Perl for years without necessarily calling it
that. Every `map`, `grep`, and `sort { $a <=> $b }` is a higher-order function
taking a block; `List::Util` gives you `first` and `reduce`. Raku takes this
style and makes it central: the list toolkit is richer, blocks gain real
signatures, lists can be lazy and infinite, and there are new ideas — junctions,
composition operators, and feed pipelines — that let you say more with less. This
chapter gathers the functional threads that ran through earlier chapters and adds
the pieces unique to Raku.

## `map`, `grep`, `sort` — the recap

The trio you know are all methods now (Chapter 4), and the block can be a bare
`{…}`, a pointy block with a signature (Chapter 17), or the `*` whatever-star.

```perl
use v5.10;
my @n = (3, 11, 2, 100, 1);
say join ',', map  { $_ * $_ }  @n;    # 9,121,4,10000,1
say join ',', grep { $_ > 3 }   @n;    # 11,100
say join ',', sort { $a <=> $b } @n;   # 1,2,3,11,100
```

```raku
my @n = 3, 11, 2, 100, 1;
say @n.map(-> $x { $x * $x });         # (9 121 4 10000 1)
say @n.grep(* > 3);                    # (11 100)
say @n.sort;                           # (1 2 3 11 100)  — numeric by default
```

Recall from Chapter 4 that Raku's `sort` compares with `cmp`, so numbers sort
numerically without a block. When you *do* want a custom order, the tidy form is
to pass a **key**: a one-argument block that maps each element to the value to
sort on. `sort(*.abs)` sorts by magnitude while keeping the originals:

```raku
say (-3, 1, -2, 5).sort(*.abs);        # (1 -2 -3 5)
```

That single-argument key form is far clearer than the two-argument comparator,
and Raku is clever enough to call it once per element rather than on every
comparison.

## `first`, `reduce`, `produce`

Perl reaches into `List::Util` for these; in Raku they are built-in methods.
`first` returns the first matching element:

```raku
my @n = 3, 11, 2, 100, 1;
say @n.first(* > 10);                  # 11
```

`reduce` folds a list down to a single value with a two-argument block:

```raku-static
say @n.reduce(* + *);                  # 117
say (1..5).reduce(* * *);              # 120   — 5!
```

Each `*` is a separate parameter here, so `* + *` is "add my two arguments".
(Chapter 11 introduced the reduction meta-operator `[+]`, which is the same idea
written even more tightly: `[+] @n`.)

`produce` is `reduce`'s cousin that keeps every intermediate result — the running
totals rather than just the final one:

```raku
say (1..5).produce(* + *);             # (1 3 6 10 15)
```

## `gather`/`take`

Perl builds a list by pushing onto an array. Raku offers a more declarative
route: `gather` runs a block, and every `take` inside it — however deeply nested
— contributes a value to the resulting sequence.

```raku
my @evens = gather for 1..10 { take $_ if $_ %% 2 };
say @evens;                            # [2 4 6 8 10]
```

The `%%` there is the "divisible by" operator (Chapter 11). The real power of
`gather`/`take` is that it produces values *lazily* and can therefore describe an
infinite generator without looping forever:

```raku
my $fib = gather {
    my ($a, $b) = 0, 1;
    loop { take $a; ($a, $b) = $b, $a + $b; }
}
say $fib[^10];                         # (0 1 1 2 3 5 8 13 21 34)
```

Nothing in that `loop` runs until you ask for elements, and only enough runs to
satisfy the ten you requested. This is impossible in Perl without an explicit
iterator object.

## Lazy and infinite lists

Laziness is not confined to `gather`. Ranges are lazy, and `map`/`grep` over a
lazy source stay lazy, so `1..Inf` is an ordinary value you can transform:

```raku
say (1..Inf).map(* ** 2).head(5);       # (1 4 9 16 25)
say (1..Inf).grep(*.is-prime).head(5);  # (2 3 5 7 11)
```

`.head(n)` takes the first *n* elements; you can also bind the lazy list to a
`@` variable and subscript it, and only the elements you touch are computed:

```raku
my @squares = (1..Inf).map(* ** 2);
say @squares[^5];                        # (1 4 9 16 25)
```

Think of laziness as "describe the whole computation, pay only for the part you
read". It turns many loops into a single declarative expression.

## Junctions

Here is an idea Perl has only recently begun to approach. A *junction* is a single
value that superimposes several values at once, combined with `any`, `all`, `one`,
or `none`. You build them with the infix forms `|` (any), `&` (all), and `^` (one):

```raku
say so 3 == (1|2|3);                    # True
say so 5 == (1|2|3);                    # False
```

The `so` coerces the result to a plain Boolean. What makes junctions magical is
**autothreading**: apply an ordinary operator or function to a junction and it
distributes across every branch, returning a new junction.

```raku
say (1|2|3) + 10;                        # any(11, 12, 13)
```

That means a whole family of loops collapses into one comparison. "Is 15 present
in the array?" and "are all the values positive?" become:

```raku
my @a = 4, 8, 15, 16, 23, 42;
say so 15 == any(@a);                    # True
say so all(@a) > 0;                      # True
```

Very recent Perl has `any` and `all` keywords that cover exactly these two
questions:

```perl
use v5.36;
use feature qw(keyword_any keyword_all);
no warnings 'experimental::keyword_any', 'experimental::keyword_all';

my @a = (4, 8, 15, 16, 23, 42);
say any { $_ == 15 } @a;      # 1
say all { $_ > 0 } @a;        # 1
```

The convergence stops there, though, and the difference is worth understanding.
Perl's `any`/`all` are *block-and-list* functions: they take a predicate, walk the
list, and return a Boolean immediately. Raku's are *values*. `any(@a)` is a
`Junction` you can store in a variable, pass to a function, and apply arbitrary
operators to — the autothreading above is not something a Perl `any` can do,
because there is nothing left over after it returns. That is why the Raku form
reads `15 == any(@a)` — comparison against a value — while the Perl form reads
`any { $_ == 15 }` — a predicate over a list.

Use the named forms `any`/`all`/`one`/`none` for readability over lists, and the
`|`/`&`/`^` operators for quick inline junctions. One caution: because a junction
is not a single definite value, do not use one where you need a concrete result —
it is a device for *asking questions*, not for carrying data.

## Function composition and partial application

Raku treats subroutines as values (`&name` refers to the routine itself), and it
gives you an operator to *compose* two of them. The composition operator is `∘`
(U+2218) with the ASCII alias `o`; `f o g` means "apply `g`, then `f`".

```raku
my &inc    = * + 1;
my &double = * * 2;
my &f = &double o &inc;                  # double(inc(x))
say f(5);                                # 12
my &g = &inc ∘ &double;                  # inc(double(x))
say g(5);                                # 11
```

Partial application — fixing some arguments now and the rest later — is the
`.assuming` method. Pass `*` for the arguments you want to leave open:

```raku
sub power($base, $exp) { $base ** $exp }
my &square = &power.assuming(*, 2);      # exp fixed at 2
say square(9);                           # 81
my &two-to = &power.assuming(2);         # base fixed at 2
say two-to(3);                           # 8
```

These are Perl's home-grown closures-returning-closures made into first-class
operations.

## Feed operators

Method chaining already reads left to right, but for a pipeline of *list*
operations Raku offers the feed operators `==>` and `<==`, which make the flow of
data explicit — think of them as a shell pipe. The rightward feed reads
top-to-bottom, and its final term is the destination:

```raku
(1..10)
    ==> grep(* %% 2)
    ==> map(* ** 2)
    ==> sort()
    ==> my @result;
say @result;                             # [4 16 36 64 100]
```

The leftward feed `<==` reads bottom-to-top, mirroring the way nested function
calls actually evaluate — the source is at the far right:

```raku
my @r2 <== sort() <== map(* + 1) <== (5, 3, 1);
say @r2;                                 # [2 4 6]
```

Note that the feed's destination is a *container* at the end of the chain, not
the left-hand side of an ordinary `=`. Reach for feeds when a pipeline reads more
clearly as a sequence of stages than as a chain of dots — many Raku programmers
prefer plain method chaining, and both are fine.

## A pure-function style

Threaded through all of this is a habit worth cultivating: prefer functions that
take values and return values over subroutines that mutate the world. `map`
instead of a loop that pushes; `reduce` instead of an accumulator; a lazy
sequence instead of a growing array. Raku's immutable `List`, its rich method
set, and its laziness all nudge you gently in that direction — the code that
results is usually shorter, easier to test, and readier for the next chapter,
where running things *in parallel* becomes almost free.

{% include nav.html %}

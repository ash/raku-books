---
title: More on X, .., and …
---

{% include menu.html %}

In the previous chapters, we often used a construct with a cross-operator. Here are a couple of examples:

```
(999...100) X* (999...100)

1..10 X* 1..10
```

The second line prints the items of the product table for the numbers from 1 to 10:

```
(1 2 3 4 5 6 7 8 9 10 2 4 6 8 10 12 14 16 18 20 3 6 9 12 15
18 21 24 27 30 4 8 12 16 20 24 28 32 36 40 5 10 15 20 25 30
35 40 45 50 6 12 18 24 30 36 42 48 54 60 7 14 21 28 35 42 49
56 63 70 8 16 24 32 40 48 56 64 72 80 9 18 27 36 45 54 63 72
81 90 10 20 30 40 50 60 70 80 90 100)
```

There are a few things to learn about such constructions.

You may have noticed two subtle differences between `999...100` and `1..10`. In one case, there are three dots, in another—only two. In the first case, the boundaries are decreasing numbers, in the second—increasing.

The two dots in Raku is the range operator. It creates a `Range`, or, in other words, an object of the `Range` type.

The three dots are the sequence operator. In our example, it creates a sequence, or an object of the `Seq` type.

You can always check the type by calling the `WHAT` method on the object (a fragment of the REPL session is shown below):

```
> (1..10).WHAT
(Range)
> (1...10).WHAT
(Seq)
```

It is also interesting to look into the source codes of Rakudo, and see which attributes the `Range` and `Seq` have.

```raku-static
my class Range is Cool does Iterable does Positional {
    has $.min;
    has $.max;
    has int $!excludes-min;
    has int $!excludes-max;
    has int $!infinite;
    has int $!is-int;
    . . .
}

my class Seq is Cool does Iterable does Sequence {
    has Iterator $!iter;
    . . .
}
```

In the `Range` object, there are the minimum and the maximum values, while in `Seq` we see an iterator.

In some cases, for example, in a simple loop, you can choose between either a range or a sequence:

```raku
.say for 1..10;
.say for 1...10;
```

But if you want to count downwards, ranges will not work:

```
> .say for 10..1;
Nil
```

With a sequence, there’s no problem:

```
> .print for 10...1;
10987654321>
```

It is wise to play with ranges and sequences before you start feeling them well. Save them in variables, use in operations, print using `say` or `dd`.

As a starting point, consider the following three operations:

```raku-static
(1, 2, 3) X* (4, 5, 6);
(1..3)    X* (4..6);
(1...3)   X* (4...6);
```

{% include nav.html %}

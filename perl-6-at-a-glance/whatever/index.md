---
title: Whatever (*)
---

{% include menu.html %}

In Perl 6, the star character `*` can be associated with one of the predefined classes, `Whatever` and `WhateverCode`.

We’ll start with an object of the `Whatever` class.

```raku
say *.WHAT; # (Whatever)
```

The construction like `1 .. *` creates a `Range` object, where its upper limit is not fixed to any particular number.

```raku
say (1 .. *).WHAT; # (Range)
```

Here is an example with a loop that prints the numbers from `5` to `10` line by line:

```raku
for (5 .. *) {
    .say;
    last if $_ == 10;
}
```

Now, try array indices and ask to take all the elements starting from the fourth one:

```raku
my @a = <2 4 6 8 10 12>;
say @a[3 .. *]; # (8 10 12)
```

The “three dots” operator in combination with a star creates a sequence.

```raku
say (1 ... *).WHAT; # (Seq)
```

You can use it when you need a lazy and potentially infinite list. A lazy list is a list whose elements are evaluated only when they are necessary for the execution of the programme.

In the following example, an array does not know its size, but you can read infinitely from it; the lazy list will supply new elements:

```raku
my @a = (100 ... *);

for (0 .. 5) {
    say "Element $_ is @a[$_]";
}
```

This programme will print five lines corresponding to the first five elements of the `@a` array, which contain values from `100` to `105`, including `105`. If you change the range in the `for` loop from `0 .. 5` to `0 .. *`, you will get a programme that prints infinitely.

```

```

It is possible to modify the algorithm for generating the new values of the sequence by giving a hint to the compiler:

```raku
my @a = (1, 2 ... *);    # step by 1
say @a[1..5];            # (2 3 4 5 6)

my @b = (2, 4 ... *);    # even numbers
say @b[1..5];            # (4 6 8 10 12)

my @c = (2, 4, 8 ... *); # powers of two
say @c[1..5];            # (4 8 16 32 64)
```

Together with a list repetition operator, `xx`, the `Whatever` object forms an infinite list containing the same value.

```raku-static
my @default_values = 'NULL' xx *;
```

Now, let’s move on to the `WhateverCode` object. It is an anonymous code block, which is a good match for simple functions, such as these:

```raku
my $f = * ** 2;  # square
say $f(16);      # 256

my $xy = * ** *; # power of any
say $xy(3, 4);   # 81
```

In Perl 6, the transformation from a code with a star to an anonymous code block is called whatever-currying. In the traditional style of programming, you introduce a variable to get the same result. In Perl 6, a compiler creates that for you. The following two examples are equivalent to the two above.

```raku
# An anonymous code block with one argument $x
my $f = -> $x {$x ** 2};
say $f(16); # 256

# A block with two arguments; names are alphabetically sorted
my $xy = {$^a ** $^b};
say $xy(3, 4); # 81
```

Whatever-currying is also happening, for example, when we want to refer to the last elements of an array using negative indices. In the following example, we pick array elements from the fourth to the second-to-last one.

```raku
my @a = <2 4 6 8 10 12>;
say @a[3 .. *-2]; # (8 10)
```

In Perl 5, you could get the last element of an array with the `-1` index. In Perl 6, the access `@a[-1]` will generate an error:

```raku-static

Unsupported use of a negative -1 subscript to index from the end; in Perl 6 please use a function such as *-1
```

So, you need to add a star:

```raku-static
say @a[*-1]; # 12
```

Here, the compiler will convert `@a[*-1]` into the following code:

```raku-static
@a[@a.elems - 1]
```

Another common use case of `WhateverCode` is to provide a compiler with a rule for generating infinite sequences.

```raku
my @f = 0, 1, * + * ... *;
say @f[1..7].join(', '); # 1, 1, 2, 3, 5, 8, 13
```

This example creates a lazy list containing the Fibonacci numbers. The `* + *` construction will be implicitly replaced with something like `{$^a + $^b}`. Note that the first two stars in the example are part of what will become an anonymous code block, while the last one is a single `Whatever` object.

```

```

{% include nav.html %}

---
title: Zip meta-operators
---

{% include menu.html %}

The zip meta-operator prefix, `Z`, combines the corresponding elements of its list operands like the zipper does. The record

```raku-static
@a Z+ @b
```

is equivalent to this (in Perl 6, the last element of an array is indexed as `*-1`, not just `-1`; see the details in Appendix):

```raku-static
((@a[0] + @b[0]), (@a[1] + @b[1]), . . . (@a[*-1] + @b[*-1]))
```

Notice that the zip meta-operator differs from the `Z` infix operator. Compare the output of the following test programme:

```raku
my @a = 1, 2, 3;
my @b = 10, 20, 30;

say @a Z+ @b; # (11 22 33)
say @a Z @b;  # ((1 10) (2 20) (3 30))
```

Here is another example with the => operator, which creates pairs:

```raku

my @a = ^5;
my @b = 'a' .. 'e';
say @a Z=> @b;
```

As you can see, the `=>` operator is used indeed:

```

(0 => a 1 => b 2 => c 3 => d 4 => e)
```

The default operator for `Z` is comma `,`. Thus, `@a Z @ b` and `@a Z, @b` produce the same result.

```

```

```raku
my @a = ^5;
my @b = 'a' .. 'e';
say @a Z, @b;
```

The output is the same as in the example in the section about list operators earlier in this chapter.

```
((0 a) (1 b) (2 c) (3 d) (4 e))
```

```

```

{% include nav.html %}

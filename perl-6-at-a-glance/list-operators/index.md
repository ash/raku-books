---
title: List operators
---

{% include menu.html %}

`xx` repeats the list the given number of times.

```raku
say (1, -1) xx 2; # ((1 -1) (1 -1))
```

Like the string `x` operator, the `xx` operator returns an empty list if the number of repetitions is zero or negative.

`Z` is the zip operator. It mixes the content of its two operands like a zipper does. The operator continues mixing while there are enough data in both operands.

The code

```raku-static
@c = @a Z @b;
```

is equivalent to the following:

```raku-static
@c = ((@a[0], @b[0]), (@a[1], @b[1]), ...);
```

Consider another example:

```raku
my @a = ^5; # A range from 0 to 5 (excluding 5)
my @b = 'a' .. 'e';
say @a Z @b;
```

It reveals the internal structure of the object that will be created after the `Z` operation:

`((0 a) (1 b) (2 c) (3 d) (4 e))`

```

```

`X` is the cross product operator, which converts the two given lists to a third one containing all the possible combinations of the elements from the original lists.

```raku-static
@c = @a X @b;
```

This is the same as the following sequence:

```raku-static
@c = ((@a[0], @b[0]), (@a[0], @b[1]), (@a[0], @b[2]), ... (@a[N], @b[0]), (@a[N], @b[1]), ... (@a[N], @b[M]));
```

The length of the two operands can be different (they are `N` and `M` in the example above).

`...` creates a sequence and is called a sequence operator.

```raku-static
my @list = 1 ... 10;
```

The operator can also count backwards:

```raku-static
my @back = 10 ... 1;
```

{% include nav.html %}

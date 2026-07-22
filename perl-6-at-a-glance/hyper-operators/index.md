---
title: Hyper-operators
---

{% include menu.html %}

Hyper-operators modify regular operators in such a way that the operation is applied to all the element of a list operand. Both unary and binary operators may be written in the hyper-operator form. To create a hyper-operator, add a pair of `>>` and/or `<<` to the operation sign.

Let’s start with a simple unary operator `!`:

```raku
my @a = (True, False, True);
my @b = !<< @a;
say @b; # False True False
```

Another example, now with the postfix operator:

```raku
my @a = (1, 2, 3);
@a>>++;
say @a; # [2 3 4]
```

In both examples, an operation was applied to each element of the given list. Keep in mind that you should avoid spaces around or inside the hyper-operator because the compiler may be confused otherwise.

```raku
my @a = ('a', 'b')>>.uc;
# You cannot type ('a', 'b') >>. uc

say @a; # [A B]
```

Hyper-operators use the angle brackets, and it is possible to make four different combinations and directions of them:

```
>>+>> <<+<< <<+>> >>+<<
```

The direction of the double brackets changes the result of the hyper-operation. If both operands are of the same length, the symmetrical forms work the same:

```raku
my @a = (1, 2, 3) >>+<< (4, 5, 6);
say @a; # [5 7 9]

my @b = (1, 2, 3) <<+>> (4, 5, 6);
say @b; # [5 7 9]
```

When the lengths of the lists in operands are different, the direction of arrows indicates whether the compiler needs to extend the shortest operand so that there are enough elements to make the operation with all the elements of the longer list.

The simplest case is a combination of a list and a scalar:

```raku
say((1, 2, 3) >>+>> 1); # (2 3 4)
```

The scalar `1` will be repeated three times.

In the next example, we have two lists, but the second one is shorter.

```raku
my @a = (1, 2, 3, 4) >>+>> (1, -1);
say @a; # [2 1 4 3]
```

Now, the second list was repeated twice and the left array was in fact added to `(1, -1, 1, -1)`. So as you see, the sharp end of the arrows points to the shorter operand.

If you reverse the order or the operands, you should also change the direction of the hyper-operator:

```raku
my @b = (1, -1) <<+<< (1, 2, 3, 4);
say @b; # [2 1 4 3]
```

If the list length is not known, use the form of the hyper-operator, where both arrows are pointing outside: `<<+>>`.

```raku
my @a = (1, -1) <<+>> (1, 2, 3, 4);
say @a; # [2 1 4 3]

my @b = (1, 2, 3, 4) <<+>> (1, -1);
say @b; # [2 1 4 3]
```

It is not possible to use the operator `>>+<<` because it expects that both operands are of the same length, and if they are not, then a runtime error occurs:

```
Lists on either side of non-dwimmy hyperop of infix:<+> are not of the same length
```

Finally, it is possible to use non-ASCII characters and use the French quotes instead of the pair of angle brackets:

```raku
say((1,2) »+« (3,4)); # (4 6)
```

{% include nav.html %}

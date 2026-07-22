---
title: Reverse operator
---

{% include menu.html %}

The prefix `R` forms the reverse operator for the infix operators, such as `/` or `cmp`. The reverse operator does the same as the original but changes the order of the operands.

If necessary, it also changes the operator’s associativity. This matters when you have more than two operands in a row. For example, in the code `$a op $b $op $c` the operators are calculated left to right; that is, first, the value of $a is evaluated. With the reverse operator, the value of $c will be calculated first in the same sequence `$a Rop $b Rop $c`.

```raku
say 2 R/ 10; # 5. Same as say 10 / 2
```

The reverse operators may be very useful together with the reduction operators. Here is an example of how you can reverse and join the values in one go:

```raku
say [R~] 'a'..'z'; # zyxwvutsrqponmlkjihgfedcba
```

{% include nav.html %}

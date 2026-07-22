---
title: Shortcut operators
---

{% include menu.html %}

`&&` returns the first of the operands, which, after being converted to a Boolean value, becomes `False`. If none are `False`, then the last element is returned. Please note that the result is not a Boolean value but the value of one of the operands (unless they are Boolean already).

```raku
say 10 && 0; # 0
say 0 && 10; # 0
say 12 && 3.14 && "" && "abc"; # empty string
```

The operator stops its work as soon as the acceptable value has been found. The values of the rest of the operands will not be calculated. That is why the operator belongs to the group of shortcut operators.

`||` returns the first operand, which is `True` in a Boolean context. The remaining operands are not evaluated.

```raku
say 10 || 0; # 10
say 0 || 10; # 10
```

`^^` returns an operand that is `True` in a Boolean context and that is, at the same time, the only one in the given list. If nothing is found, `Nil` is returned. As soon as the operator sees the second `True` value, it stops evaluating the rest, because the result is already known.

```raku
say 0 ^^ '' ^^ "abc" ^^ -0.0;  # abc
say 0 ^^ '' ^^ "abc" ^^ -10.0; # Nil
```

`//` returns the first defined operand. The operator is called a defined-or operator. It is also is a shortcut operator.

```raku
my $x;
my $y = 42;
my $z;
say $x // $y // $z; # 42
```

{% include nav.html %}

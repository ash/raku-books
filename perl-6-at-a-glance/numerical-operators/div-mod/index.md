---
title: div, mod
---

{% include menu.html %}

`div` is the integer division operator. If the floating point is truncated, the result is rounded to the preceding lower integer.

```raku
say 10 div 3;  # 3
say -10 div 3; # -4
```

`mod` is another form of the modulo:

```raku
say 10 % 3;   # 1
say 10 mod 3; # 1
```

```

```

Unlike the `/` and `%` operators, the `div` and `mod` forms do not cast the operands to the numeric value. Compare the following two examples.

```raku
say 10 % "3"; # 1
```

```

```

With a mod operator, an error occurs:

```raku-static
say 10 mod "3";

Calling 'infix:<mod>' will never work with argument types (Int, Str) 
Expected any of: :(Real $a, Real $b)
```

```

```

To satisfy the requirements, you may make the type conversion explicitly using either the `+` prefix operator:

```raku
say 10 mod +"3"; # 1
```

```

```

or calling the `.Int` method:

```raku
say 10 mod "3".Int; # 1
```

```

```

`%%` is the so-called divisibility operator: it tells if the integer division with no remainder is possible for the given pair of operands.

```raku
say 10 %% 3; # False
say 12 %% 3; # True
```

```

```

{% include nav.html %}

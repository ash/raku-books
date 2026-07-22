---
title: !, not
---

{% include menu.html %}

`!` is the Boolean negation operator.

```raku
say !True;     # False
say !(1 == 2); # True
```

The `not` operator does the same but has lower precedence.

```raku-nobrowser

say not False; # True
```

```

```

`+` is the unary plus operator, which casts its operand to the numerical context. The action is equivalent to the call of the `Numeric` method.

```raku
my Str $price = '4' ~ '2';
my Int $amount = +$price;

say $amount;        # 42
say $price.Numeric; # 42
```

```

```

We will see one of the important use cases of the unary plus in Chapter 6: `+$/`. That construction converts an object of the `Match` class that contains information about the matched part of the regular expression into a number.

`-` is a unary minus, which changes the sign of its operand. Because this operator silently calls the `Numeric` method, it can also cast the context, as it does the unary plus operator.

```raku
my Str $price = '4' ~ '2';
say -$price; # -42
```

```

```

{% include nav.html %}

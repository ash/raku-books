---
title: before, after
---

{% include menu.html %}

`before` and `after` are the comparison operators, which work with operands of different types. It returns a Boolean value of either True or False depending on which operand was considered to be ordered earlier or later.

Type coercion is similar to how it happens with the `cmp` operator.  Remember that depending on the data types the comparison of similar-looking strings or numbers may give different results because the strings are compared alphabetically, while the numbers are ordered by their values:

```raku
say 10 before 2;      # False
say '10' before '2';  # True
say 10 before 20;     # True
say '10' before '20'; # True
```

`eqv` is an operator that tests the two operands for equivalence. It returns the `True` value if the operands are of the same type and contain the same values.

```raku
my $x = 3;
my $y = 3;
say $x eqv $y; # True
```

An example with a bit more complex data structures:

```raku
my @a = (3, 4);
my @b = (3, 4, 5);
@b.pop;
say @a eqv @b; # True
```

Note that because the integer and the floating-point types are different data types, comparing two equal numbers may give a `False` result. The same applies to the comparison with a string containing a numeric value.

```raku
say 42 eqv 42.0; # False
say 42 eqv "42"; # False
```

It is even trickier when one of the operands is of the `Rat` value.

```raku
say 42 eqv 84/2;       # False, 84/2 is Rat
say 42 eqv (84/2).Int; # True, the value is cast to Int
```

`===` returns a `True` value if both operands are the same value. Otherwise, it returns `False`. This operator is also known as the value identity operator.

```raku
class I { }

# Three different instances
my $i = I.new;
my $ii = I.new;
my $iii = I.new;

my @a = ($i, $ii, $iii);
for @a -> $a {
    for @a -> $b {
        say $a === $b;
        # Prints True only when $a and $b are pointing
        # to the same element of the @a array.
    }
}
```

`=:=` is the operator to check if the operands refer to the same object. A Boolean value is returned. The operator is called the container identity operator.

```raku-nobrowser
my $x = 42;
my $y := $x;

say $x =:= $y; # True
say $y =:= $x; # True
```

`~~` is the smartmatch operator. It compares the objects and tries to work correctly with the operands of any type (that is why the operator is called smart).

```raku
say 42 ~~ 42.0; # True
say 42 ~~ "42"; # True
```

The result of the smartmatching depends on the operand order.

Consider the following:

```raku
say "42.0" ~~ 42; # True
say 42 ~~ "42.0"; # False
```

That behaviour is explained by how the operator works internally. First, it calculates the value of the right-hand side operand; then it calls the `ACCEPTS` method on it, passing it the variable `$_` with a reference to the left-hand side operand. Each data type defines its own variant of the `ACCEPTS` method. For example, it compares strings in the `Str` class, and integers in the `Int` class.

The preceding two examples may be re-written as the following form, where the asymmetry is clearly visible:

```raku-nobrowser
say 42.ACCEPTS("42.0"); # True
say "42.0".ACCEPTS(42); # False
```

{% include nav.html %}

---
title: Bool
---

{% include menu.html %}

The usage of the `Bool` variables is straightforward although there are some details about which you might want to know. The Bool type is a built-in enumeration and provides two values: `True` and `False` (or, in a full form, `Bool::True` and `Bool::False`). It is permissible to increment or decrement the Boolean variables:

```raku
my $b = Bool::True;
$b--;
say $b; # prints False

$b = Bool::False;
$b++;
say $b; # True
```

The Perl 6 objects (namely, all variables) contain the `Bool` method, which converts the value of the variable to one of the two Boolean values:

```raku
say 42.Bool; # True

my $pi = 3.14;
say $pi.Bool; # True

say 0.Bool;    # False
say "00".Bool; # True
```

Similarly, you may call the `Int` method on a variable and get the integer representation of the Boolean values (or values of any other types):

```raku
say Bool::True.Int; # 1
```

{% include nav.html %}

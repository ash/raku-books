---
title: Int
---

{% include menu.html %}

The `Int` type is intended to host integer variables of arbitrary size. For example, no digit is lost in the following assignment:

```raku
my Int $x =
    12389147319583948275874801735817503285431532;
say $x;
```

A special syntax exists for defining integers with an other-than-10 base:

```raku
say :16<D0CF11E0>
```

Also, it is allowable to use the underscore character to separate digits so that big numbers can be read more easily:

```raku-static

my Int $x = 735_817_503_285_431_532;
```

Of course, when you print the value, all the underscores are gone.

On the `Int` object, you may call some other handy methods, for example, to convert a number to a character or to check if the integer in hand is prime (yes, `is-prime` is a built-in method!).

```raku
my Int $a = 65;
say $a.chr; # A

my Int $i = 17;
say $i.is-prime; # True

say 42.is-prime; # False
```

{% include nav.html %}

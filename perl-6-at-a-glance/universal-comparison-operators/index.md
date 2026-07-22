---
title: Universal comparison operators
---

{% include menu.html %}

There are a few operators, which can compare both strings and numbers, or even compound objects like pairs.

`cmp` compares two objects and returns a value of the `Order` type, either `Less`, or `Same`, or `More`.

```raku
say 2 cmp 2;   # Same
say 2 cmp 2.0; # Same
say 1 cmp 2;   # Less
say 2 cmp 1;   # More

say "a" cmp "b";        # Less
say "abc" cmp "b";      # Less
say "bc" cmp "b";       # More
say "abc" cmp "ABC".lc; # Same
```

```raku
my %a = (a => 1);
my %b = (a => 1);
say %a cmp %b; # Same
```

When the two operands are of different types (for example, one is a number and the other is a string) you have to be careful and think that the compiler may choose from one of the overloaded versions of the `cmp` operator. Here is the list of them:

```raku-static
proto sub infix:<cmp>(Any, Any)
    returns Order:D is assoc<none>

multi sub infix:<cmp>(Any,       Any)
multi sub infix:<cmp>(Real:D,    Real:D)
multi sub infix:<cmp>(Str:D,     Str:D)
multi sub infix:<cmp>(Enum:D,    Enum:D)
multi sub infix:<cmp>(Version:D, Version:D)
```

(The `:D` in the declarations is not a smiley; this is a trait indicating that the argument must be defined.)

So, when you ask to compare a string to a number, the most probable choice will be the one having the signature with two strings: `(Str:D, Str:D)`. So, both operands will be cast to strings:

```raku
say "+42" cmp +42; # Less
say ~42 cmp +42;   # Same
```

{% include nav.html %}

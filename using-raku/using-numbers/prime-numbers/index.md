---
title: 27. Prime numbers
---

{% include menu.html %}

*Decide if the given number is a prime number.*

Prime numbers are those that can be divided only by 1, and by themselves.

The language provides us with a built-in support, the `is-prime` routine, for checking if the number is prime. There are two ways of using it.

First, as a built-in function:

```raku
say 'Prime' if is-prime(17);
```

Second, as a method on an object of the `Int` type:

```raku
my $n = 15;
say $n.is-prime
    ?? "$n is prime"
    !! "$n is not prime"
    ;
```

Here, the ternary operator `??` … `!!` is used. This code prints either of the strings, depending on the result of calling `$n.is-prime`:

```
17 is prime

15 is not prime
```

Notice that the `is-prime` routine contains a hyphen in its name, which is a valid character for identifier names in Raku.

{% include nav.html %}

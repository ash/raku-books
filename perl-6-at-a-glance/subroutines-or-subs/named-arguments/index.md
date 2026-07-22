---
title: Named arguments
---

{% include menu.html %}

Apart from the positional parameters (those that have to go in the same order both in the sub definition and in the sub call), Perl 6 allows named variables, somewhat similar to how you pass a hash to a Perl 5 subroutine. To declare a named parameter, a colon is used:

```raku-static
sub power(:$base, :$exponent) {
    return $base ** $exponent;
}
```

Now, the name of the variable is the name of the parameter, and the order is not important anymore.

```raku-static
say power(:base(2), :exponent(3)); # 8
say power(:exponent(3), :base(2)); # 8
```

It is also possible to have different names for the named arguments and those variables, which will be used inside the sub. To give a different name, put it after a colon:

```raku-static
sub power(:val($base), :pow($exponent)) {
    return $base ** $exponent;
}
```

Now the sub expects new names of the arguments.

```raku-static
say power(:val(5), :pow(2)); # 25
say power(:pow(2), :val(5)); # 25
```

Alternatively, you can use the fatarrow syntax to pass named parameters as it is done in the following example:

```raku-static

say power(val => 5, pow => 2); # 25
```

{% include nav.html %}

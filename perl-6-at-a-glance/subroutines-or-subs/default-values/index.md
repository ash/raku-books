---
title: Default values
---

{% include menu.html %}

Perl 6 also allows specifying the default values of the sub’s arguments. Syntactically, this looks like an assignment.

```raku
sub i-live-in(Str $city = "Moscow") {
    say "I live in $city.";
}

i-live-in('Saint Petersburg');
i-live-in(); # The default city
```

It is also possible to pass values that are not known at the compile phase. When the default value is not a constant, it will be calculated at runtime.

```raku
sub to-pay($salary, $bonus = 100.rand) {
    return ($salary + $bonus).floor;
}

say to-pay(500, 50); # Always 550 net.
say to-pay(500);     # Any number between 500 and 600.
say to-pay(500);     # Same call but probably different output.
```

The “default” value will be calculated whenever it is required. Please also note that both `rand` and `floor` are called as methods, not as functions.

It is also possible to use previously passed parameters as default values:

```raku
sub f($a, $b = $a) {
    say $a + $b;
}

f(42);    # 84
f(42, -1) # 41
```

Optional parameters or parameters with default values must be listed after all the required ones because otherwise, the compiler will not be able to understand which is which.

{% include nav.html %}

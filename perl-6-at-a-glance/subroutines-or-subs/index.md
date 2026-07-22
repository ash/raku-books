---
title: Subroutines, or subs
---

{% include menu.html %}

For a sub, which takes no arguments, its definition and the call are very straightforward and easy.

```raku-static
sub call-me {
    say "I'm called"
}
```

```raku-static
call-me;
```

The syntax for declaring a sub’s parameters is similar to what other languages (including Perl 5.20 and higher) provide.

```raku-static
sub cube($x) {
    return $x ** 3;
}
```

```raku-static
say cube(3); # 27
```

The required parameters are a comma-separated list in the parentheses immediately after the sub name. No other keywords, such as `my`, are required to declare them.

```raku
sub min($x, $y) {
    return $x < $y ?? $x !! $y;
}

say min(-2, 2);  # -2
say min(42, 24); # 24
```

(`?? ... !!` is a ternary operator in Perl 6. Also, there’s a built-in operator `min`; see the details in the Chapter 2.)

The above-declared arguments are required; thus, if a sub is called with a different number of actual arguments, an error will occur.

{% include nav.html %}

---
title: state variables
---

{% include menu.html %}

State variables (declared with the keyword `state`) appeared in Perl 5.10 and work in Perl 6. Such variables are initialized during the first call and keep their values in subsequent sub calls.

It is important to keep in mind that a single instance of the variable is created. Let us return to the example with a counter and replace the `my` declaration with the `state` one. The closure will now contain a reference to the same variable.

```raku-static
sub seq($init) {
     state $c = $init;
     return {$c++};
}
```

```

```

What happens when you create more than one closure?

```raku-static
my $a = seq(1);
my $b = seq(42);
```

All of them will reference the same variable, which will increase after calling either `$a()` or `$b()`.

```raku-static
say $a(); # 1
say $a(); # 2
say $b(); # 3
say $a(); # 4
say $b(); # 5
```

```

```

{% include nav.html %}

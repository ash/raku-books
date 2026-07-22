---
title: Lexical variables
---

{% include menu.html %}

Lexical variables in Perl 6 are those declared with the `my` keyword. These variables are only visible within the block where they were declared. If you tried accessing them outside the scope, you’d get the error: `Variable '$x' is not declared`.

```raku
{
     my $x = 42;
     say $x; # This is fine
}
# say $x;    # This is not
```

To “extend” the scope, lexical variables can be used in closures. In the following example, the `seq` sub returns a block, which uses a variable defined inside the sub.

```raku-static
sub seq($init) {
     my $c = $init;
     return {$c++};
}
```

The sub returns a code block containing the variable `$c`. After the sub’s execution, the variable will not only still exist but also will keep its value, which you can easily see by calling a function by its reference a few times more.

```raku-static
my $a = seq(1);

say $a(); # 1
say $a(); # 2
say $a(); # 3
```

It is possible to create two independent copies of the local variable.

```

```

```raku-static
my $a = seq(1);
my $b = seq(42);
```

To see how it works, call the subs a few times:

```raku-static

say $a(); # 1
say $a(); # 2
say $b(); # 42
say $a(); # 3
say $b(); # 43
```

{% include nav.html %}

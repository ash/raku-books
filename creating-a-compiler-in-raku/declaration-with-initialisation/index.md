---
title: Declaration with initialisation
---

{% include menu.html %}

I hope you noticed how easy it was to make the recent changes comparing to the material in the first chapters. This section brings another example of this kind.

Let us simplify the creation of variables and allow declarations with an optional assignment. So instead of

```raku-static
my x;
x = 10;
```

we can write both commands in one line:

```raku-static
my x = 10;
```

Declaration of the variable is handled by the `variable-declaration` rule, thus let’s update it with an optional assignment clause:

```raku-static
rule variable-declaration {
    'my' <variable-name> [ '=' <expression> ]?
}
```

In the action, check if there was an expression, and use its value:

```raku-static
method variable-declaration($/) {
    %var{$<variable-name>} =
        $<expression> ?? $<expression>.made !! 0;
}
```

Rewrite the test program using these additions:

```raku-static
my pi = 3.1415926;
my r = 6371; # km

my d = 2 * pi * r;
say d;
```

The program prints the result, and we only have less than 200 lines of code (including empty lines and the lines with a single curly brace in it). Raku grammars are really great!

{% include nav.html %}

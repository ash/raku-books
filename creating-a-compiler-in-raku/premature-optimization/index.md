---
title: Premature optimization
---

{% include menu.html %}

Are there any ways to make the code a bit more attractive? There are a few. We try two approaches to unify the calls. The goal is to avoid repeating the longs lines of code, where the only difference is an operand sign, e. g.:

```raku-static
$/.make($<number>[0].made + $<number>[1].made);
```

and

```raku-static
$/.make($<number>[0].made - $<number>[1].made);
```

In both cases, the operator is surrounded by two operands, and that’s a good candidate for a regular function:

```raku-static
class CalculatorActions {
    sub addition($a, $b) {
        $a + $b
    }

    sub subtraction($a, $b) {
        $a - $b
    }

    . . .
}
```

Both functions can be placed inside the `CalculatorActions` class, and when they are called, no additional arguments pointing to the instance of the class are passed to it by Raku. To make a common entry point to both functions, we’ll create a hash that keeps references to them:

```raku-static
class CalculatorActions {
    my %operation =
        '+' => &addition,
        '-' => &subtraction;

    . . .
}
```

Now it is quite easy to call a function according to the operator:

```raku-static
method TOP($/) {
    $/.make(%operation{~$<op>}(
        $<number>[0].made, $<number>[1].made));
}
```

Another interesting option to simplify the code and get rid of explicit `if` checks is to use multiple dispatch.

```raku-static
class CalculatorActions {
    multi sub operation('+', $a, $b) {
        $a + $b
    }

    multi sub operation('-', $a, $b) {
        $a - $b
    }

    method TOP($/) {
        $/.make(operation(~$<op>, 
                          $<number>[0].made,
                          $<number>[1].made));
    }

    . . .
}
```

Here, the operator sign is passed to the `operation` function, and the compiler chooses which candidate to call: either the `operation` defined with a plus or the `operation` that needs a minus as its first argument. The Raku compiler does this job for us with pleasure.

{% include nav.html %}

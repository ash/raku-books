---
title: It is never enough
---

{% include menu.html %}

But before making the next step, let us fix one tiny element that we introduced earlier, because of which we are now unable to parse some expressions.

Consider two assignments with expressions.

```raku-static
my x = 10;
my y = 2 * x;
my z = x * 2;

say "$x, $y, $z";
```

There should be no difference between expressions assigned to `y` and `z`, but the parser refuses to accept the second expression, `x * 2`. This happens at the place where a variable catches control in the grammar:

```raku-static
rule value {
    | <variable-name> <index>?
    | <expression>
    | <string>
}
```

In fact, as we have the AST now, it is fine to let the variable be a part of an `expression`, and we can safely remove that alternative:

```raku-static
rule value {
    | <expression>
    | <string>
}
```

This small change restores the parser, and both `2 * x` and `x * 2`, as well as `x * x` can be parsed now.

In such cases, it is important not only to fix the grammar, actions or evaluator, but also to create a regression test to avoid the same bug in the future:

```raku-static
my x = 10;
my y = 2 * x;
my z = x * 2;
my q = x * x;
my d = 2 * 2;

say "$x, $y, $z"; ## 10, 20, 20
say "$q, $d"; ## 100, 4
```

{% include nav.html %}

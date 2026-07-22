---
title: Allowing parentheses
---

{% include menu.html %}

The last touch to the calculator design is making it understand parentheses. Although it may seem a difficult task, in reality the implementation is rather simple. This is because anything within parentheses is another expression that follows the very same grammatical rules. In other words, if you see parentheses, you can recursively start from `TOP`.

After you compute the value inside parentheses, you get a single value, thus you can treat it as any other number. To extend the parser, just make a new `value` rule out of the `number` and list two alternatives there:

```raku-static
rule factor {
    <value>* %% <op3>
}

rule value {
    | <number>
    | '(' <TOP> ')'
}
```

The `value` method picks up the value made on the previous level:

```raku-static
method value($/) {
    $/.make($<number> ?? $<number>.made !! $<TOP>.made);
}
```

That’s it. Only three simple changes and we can parse much more complicated expressions:

```
ok 18 - 10 * (20 - 30) = -100
ok 19 - 10 * 20 - 30 = 170
ok 20 - (5 * 6) = 30
ok 21 - (10) = 10
ok 22 - 1 - (5 * (3 + 4)) / 2 = -16.5
```

The calculator is ready. In the next chapter, we will integrate it to the translator so that it can parse arithmetic expressions that involve variables.

{% include nav.html %}

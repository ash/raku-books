---
title: Adding more power
---

{% include menu.html %}

In this section, we will make our calculator a bit more versatile as we are going to add the power operator, `**`. The difference to the previous sets of operators is that the power operator has even higher precedence and must be processed first, before any multiplication or addition.

The operator can be added quite similarly to what we did earlier for the `*` and `/` operators. Let us replace the `factor` rule and define the token for the operator itself:

```raku-static
rule factor {
    <number>* %% <op3>
}

token op3 {
    '**'
}
```

Another subtle change that needs to be done is to add whitespaces to the number token. You either can do it explicitly:

```raku-static
token number {
    <ws> \d+ <ws>
}
```

Or implicitly by converting the token to a rule:

```raku-static
rule number {
    \d+
}
```

Add support of the new operator in the actions class:

```raku-static
multi sub operation('**', $a is rw, $b) {
    $a **= $b
}

method factor($/) {
    $/.make(process($<number>, $<op3>));
}
```

All hard work has been done (it was simple, wasn’t it?). The calculator is now handling five operators:

```
ok 14 - 2 ** 3 = 8
ok 15 - 2 + 3 ** 4 = 83
ok 16 - 1 + 2 * 3 ** 4 - 5 * 6 = 133
ok 17 - 2 ** 3 ** 4 = 4096
```

{% include nav.html %}

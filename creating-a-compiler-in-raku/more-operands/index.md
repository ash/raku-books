---
title: More operands
---

{% include menu.html %}

The grammar and the actions are now smart enough to parse and evaluate expressions having two values in it, but it does not work with more complicated examples like . You can try but it will not work, as at the `TOP` level it is restricted by the rule with two numbers: `<number> <op> <number>`.

In the grammar, the new additions can be expressed by the `*` quantifier:

```raku-static
rule TOP {
    <number> [<op> <number> <ws>]*
}
```

The `<ws>` token is a built-in tool to match optional whitespace. With this change, we also allowed expressions that contain a single number. So, the following test cases all match:

```raku-static
my @cases =
    '3 + 4', '3 - 4',
    '7',
    '1 + 2 + 3', '1 + 3 + 5 + 7';
```

The two functions that do real calculations must also be adapted to accept more than two values:

```raku-static
multi sub operation('+', @values) {
    [+] @values
}

multi sub operation('-', @values) {
    [-] @values
}
```

Using a reduction operation simplifies the syntax a lot at this point. Finally, prepare an array of the values that one of these multi-functions receives:

```raku-static
method TOP($/) {
    $/.make(operation(~$<op>[0], $<number>.map: *.made));
}
```

To get the numbers from the AST tree, the `map` method is used here. The `*.made` construction is a `WhateverCode` block that is executed for each element of the array of `$<number>`s.

As we already expect that the calculator must work with single numbers, a small extension is required. With a single number, there is no operator in the expression:

```raku-static
method TOP($/) {
    if $<op> {
        $/.make(operation(~$<op>[0], $<number>.map: *.made));
    }
    else {
        $/.make($<number>[0].made);
    }
}
```

Run the test and check that all the test cases are properly evaluated:

```
3 + 4 = 7
3 - 4 = -1
7 = 7
1 + 2 + 3 = 6
1 + 3 + 5 + 7 = 16
```

{% include nav.html %}

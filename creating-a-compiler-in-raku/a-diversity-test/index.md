---
title: A diversity test
---

{% include menu.html %}

The beauty and the simplicity of the reduction form of the operators made it possible to express the action in a few characters but it made impossible to evaluate the expression with different operators, for instance, . To handle such examples, a loop over the operators and the operands can be organised.

At the top level, you’ve got to walk along the numbers and take the operator next to it. Here is an example of how you can loop over the values:

```raku-static
method TOP($/) {
    my @numbers = $<number>.map: *.made;
    my $make = @numbers.shift;

    operation(~$<op>.shift, $make, @numbers.shift)
        while @numbers.elems;

    $/.make($make);
}
```

To simplify the `while` loop, the `operation` multi-functions now update one of their arguments:

```raku-static
multi sub operation('+', $a is rw, $b) {
    $a += $b
}

multi sub operation('-', $a is rw, $b) {
    $a -= $b
}
```

Again, the code looks compact and, what is even more important, it works correctly.

```
7 + 8 - 3 = 12
14 - 4 = 10
14 - 4 - 3 = 7
100 - 200 + 300 + 1 - 2 = 199
```

{% include nav.html %}

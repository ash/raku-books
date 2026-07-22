---
title: Sub overloading with subtypes
---

{% include menu.html %}

Multi subs can be made even more specific by using subtypes. In Perl 6, subtypes are created with the `subset` keyword. A subtype definition takes one of the existing types and adds a restriction to select the values to be included in the subtype range.

The following lines give a clear view of how subtypes are defined. From the same integer type, `Int`, the `Odd` subtype selects only the odd numbers, while the `Even` subtype picks only the even numbers.

```raku-static
subset Odd of Int where {$^n % 2 == 1};
subset Even of Int where {$^n % 2 == 0};
```

```

```

Now, the subtypes can be used in the signatures of the multi subs. The `testnum` function has two versions, one for odd and one for even numbers.

```raku-static
multi sub testnum(Odd $x) {
    say "$x is odd";
}

multi sub testnum(Even $x) {
    say "$x is even";
}
```

Which function will be used in a call, `testnum($x)`, depends on the actual value of the variable `$x`. Here is an example with the loop, calling either `testnum(Even)` for even numbers or `testnum(Odd)` for odd numbers.

`for 1..4 -> $x {`

```raku-static
    testnum($x);
}
```

The loop prints a sequence of alternating function call results, which tells us that Perl 6 made a correct choice by using the rules provided in the subtype definitions.

```
1 is odd
2 is even
3 is odd
4 is even
```

{% include nav.html %}

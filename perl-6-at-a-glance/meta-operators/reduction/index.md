---
title: Reduction
---

{% include menu.html %}

For any infix operator `op` the reduction form `[op]` also exists. The reduction operator takes a list, enrols its values, and inserts the operator between them.

Examine the example with the `[*]` reduction operator:

```
[*] 1..5
```

The form above is equivalent to the following line:

```
1 * 2 * 3 * 4 * 5
```

Reduction operators also will be automatically created for the user-defined operators. For example, create the operator that accumulates the sum of every pair of operands that it ever received. Notice the `state` variable, which works as it does in regular subs, keeping the value between the sub calls.

```raku
sub infix:<pairsum>($a, $b) {
    state $sum = 0;
    $sum += $a + $b;
}

say [pairsum] 1, 2, 3; # 9
say [pairsum] 1, 2, 3; # 27
```

To understand the result, let’s add the debugging output to the operator body:

```raku-static
sub infix:<pairsum>($a, $b) {
    state $sum = 0;
    say "[$a + $b]";
    $sum += $a + $b;
}
```

Also note that the function returns the last calculated value; that’s why there is no need for an explicit `return $sum` statement.

So, the call of `[pairsum] 1, 2, 3` prints the following lines:

```
[1 + 2]
[3 + 3]
```

It is important to realise that the second call receives the values 3 and 3, not 2 and 3 from the original sub call. This is because in the second call, the left operand will contain the previously calculated value, which is also 3 at that moment.

{% include nav.html %}

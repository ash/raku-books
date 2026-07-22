---
title: Testing the code
---

{% include menu.html %}

So far, we’ve got a calculator that can perform four arithmetic operations with an arbitrary amount of numbers in the expression. You can come up with test cases, but you probably don’t want to calculate the correct result in your head and check it against each test case.

In Raku, there is the `Test` module that significantly helps to simplify the test cases loop. The module exports a few functions, and we’ll be using one of them, named `is`. As the syntax of the calculator expressions coincides with Raku’s, let us ask it to check the result:

```raku-static
use Test;

. . .

for @cases -> $test {
    my $result = Calculator.parse(
        $test, :actions(CalculatorActions)).made;
    my $correct = EVAL($result);
    is($result, $correct, "$test = $correct");
}
```

Try different test cases, including those with a mixture of operators. For example:

```
ok 10 - 3 * 4 = 12
ok 11 - 100 / 25 = 4
ok 12 - 1 + 2 * 3 = 7
ok 13 - 1 + 2 - 3 * 4 / 5 = 0.6
```

{% include nav.html %}

---
title: Conditional operators
---

{% include menu.html %}

So far, the `if` test can only check if the value is zero or not. Let us make it more powerful and allow conditional and Boolean operators:

```raku-static
|  &  <  <=  >  >=  ==  !=
```

We are not going to introduce a Boolean data type, but instead we will add the operators to existing expressions. It makes `3 + n` and `x < y` are both valid expressions, and they both can be used as a condition of the `if` test.

The above listed operators are binary operators and have precedence lower than arithmetic operators `+` and `-`. Among themselves, `&` has higher precedence. So, we have to update the `op` tokens in the grammar and add the new operators:

```raku-static
multi token op(1) {
    | '|'
    | '<' | '>'
    | '<=' | '>='
    | '==' | '!='
}

multi token op(2) {
    '&'
}
```

We also have to update the rest to explicitly give the precedence:

```raku-static
multi token op(3) {
    '+' | '-'
}

multi token op(4) {
    '*' | '/'
}

multi token op(5) {
    '**'
}

multi rule expr(6) {
    | <number>
    | <variable-name> <index>?
    | '(' <expression> ')'
}
```

Add the functions to the `AST::MathOperations` class:

```raku-static
multi sub operation('|', $a, $b) {
    $a || $b
}

multi sub operation('&', $a, $b) {
    $a && $b
}

multi sub operation('<', $a, $b) {
    $a < $b
}

multi sub operation('<=', $a, $b) {
    $a <= $b
}

multi sub operation('>', $a, $b) {
    $a > $b
}

multi sub operation('>=', $a, $b) {
    $a >= $b
}

multi sub operation('!=', $a, $b) {
    $a != $b
}

multi sub operation('==', $a, $b) {
    $a == $b
}
```

We rely on Raku’s operators here. Another alternative would be to only generate 1 or 0, for example:

```raku-static
multi sub operation('<', $a, $b) {
    $a < $b ?? 1 !! 0
}
```

In the test, try different operators and their combinations:

```raku-static
my x = 10;
my y = 20;

if x > y say ">" else say "<"; ## <
if x < y say ">" else say "<"; ## >

if x != y say "!=" else say "=="; ## !=
if x != x say "!=" else say "=="; ## ==

if x == y say "==" else say "!="; ## !=
if x == x say "==" else say "!="; ## ==

if 5 <= 5 say "5 <= 5"; ## 5 <= 5
if 5 <= 6 say "5 <= 6"; ## 5 <= 6

if 5 >= 5 say "5 >= 5"; ## 5 >= 5
if 6 >= 5 say "6 >= 5"; ## 6 >= 5

if (10 > 1) & (5 < 50) say "OK 1"; ## OK 1
if (10 < 1) | (5 < 50) say "OK 2"; ## OK 2
```

{% include nav.html %}

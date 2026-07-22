---
title: Algebraic identities
---

{% include menu.html %}

Some expressions can be simplified even when one of the operands is not known. Adding zero or multiplying by one never changes the other operand; multiplying by zero always gives zero. Such rules are called algebraic identities. A small helper checks whether a node is a given number literal:

```raku-static
sub is-number($node, $n) {
    return $node ~~ AST::NumberValue && $node.value == $n;
}
```

The rules are added to the same `optimize-node` candidate for `AST::MathOperations`, after the constant folding, and only for the simplest case of two operands:

```raku-static
if @operands.elems == 2 {
    my ($a, $b) = @operands;
    my $op = $node.operators[0];

    return $a if $op eq '+' && is-number($b, 0);
    return $b if $op eq '+' && is-number($a, 0);
    return $a if $op eq '-' && is-number($b, 0);
    return $a if $op eq '*' && is-number($b, 1);
    return $b if $op eq '*' && is-number($a, 1);
    return $a if $op eq '/' && is-number($b, 1);

    return AST::NumberValue.new(value => 0)
        if $op eq '*' && (is-number($a, 0) || is-number($b, 0));
}
```

This time, the optimised tree is not just smaller: whole operations dissolve. For `x + 0`, the addition disappears, and a bare `AST::Variable` node is all that remains:

```
AST::ScalarDeclaration.new(
    variable-name => "y",
    value => AST::Variable.new(variable-name => "x", . . .)
)
```

A word of caution before you invent more rules. An optimisation must never change the behaviour of a program, and the boundary between safe and unsafe rules is sometimes very thin. It is tempting to add rules that turn `x - x` into 0 or `x / x` into 1, but if `x` is zero, the division is a runtime error, and the ’optimised’ program would silently hide it. Even our `x * 0` rule bends the border a little: if `x` holds a string, the original program fails at run time, while the optimised one happily prints 0. For Lingua, we accept this; a production compiler has to be much more careful. And, as always, a test:

```raku-static
my x = 5;
say x + 0; ## 5
say 0 + x; ## 5
say x - 0; ## 5
say x * 1; ## 5
say 1 * x; ## 5
say x / 1; ## 5
say x * 0; ## 0
say 0 * x; ## 0
```

{% include nav.html %}

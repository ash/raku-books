---
title: Constant folding
---

{% include menu.html %}

The first real optimisation is the classic one: constant folding. If all the operands of an arithmetic node are number literals, the whole node can be replaced with a single literal that carries the result.

Where does the result come from? Here comes the reward for the design we chose in Chapter 9. An `AST::MathOperations` node knows how to compute itself: that is its `value` method, which the evaluator calls at run time. Nothing prevents the optimiser from calling the very same method at compile time:

```raku-static
multi method optimize-node(AST::MathOperations $node) {
    my @operands = $node.operands.map: { self.optimize-node($_) };

    my $new = AST::MathOperations.new(
        operators => $node.operators,
        operands => @operands,
    );

    if all(@operands) ~~ AST::NumberValue {
        return AST::NumberValue.new(value => $new.value);
    }

    return $new;
}
```

The operands are optimised first, and this detail makes the folding work from the inside out: in `2 + 3 * 4`, the inner multiplication node collapses to 12 first, and then the outer addition sees two number literals and collapses to 14. The `all` junction expresses ’every operand is a literal’ in one readable line.

To see the effect, dump the tree of a one-line program `my x = 2 + 3 * 4;` before and after the optimisation. Before, the value of the declaration is a tree of seven nodes:

```
AST::ScalarDeclaration.new(
    variable-name => "x",
    value => AST::MathOperations.new(
        operators => Array[Str].new("+"),
        operands => Array[ASTNode].new(
            AST::NumberValue.new(value => 2),
            AST::MathOperations.new(
                operators => Array[Str].new("*"),
                operands => Array[ASTNode].new(
                    AST::NumberValue.new(value => 3),
                    AST::NumberValue.new(value => 4)
                )
            )
        )
    )
)
```

After, it is a single node:

```
AST::ScalarDeclaration.new(
    variable-name => "x",
    value => AST::NumberValue.new(value => 14)
)
```

The folding also covers the comparison and Boolean operators, as they live in the same `AST::MathOperations` nodes. In `if 1 + 1 == 2`, the whole condition becomes a single node containing `True`, which is exactly the value the runtime would produce. Add a test file:

```raku-static
my x = 2 + 3 * 4;
say x; ## 14
say 10 - 2 ** 3; ## 2
my y = x + 2 * 3;
say y; ## 20
if 1 + 1 == 2 say "arithmetic works"; ## arithmetic works
```

In the expression `x + 2 * 3`, only the multiplication is folded: `x` is a variable, and its value is not known at compile time. The node stays an `AST::MathOperations`, but with one operand fewer to compute at run time.

{% include nav.html %}

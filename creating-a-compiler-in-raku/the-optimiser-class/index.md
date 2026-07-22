---
title: The optimiser class
---

{% include menu.html %}

The optimiser lives in a new module, LinguaOptimizer.pm, next to the evaluator. Its interface is a single method `optimize` that takes the top node of a tree and returns a new top node:

```raku-static
use LinguaAST;

class LinguaOptimizer {
    method optimize(AST::TOP $top) {
        return AST::TOP.new(
            statements => self.optimize-list($top.statements),
        );
    }

    method optimize-list(@statements) {
        my @result;
        for @statements -> $statement {
            @result.push(self.optimize-node($statement));
        }
        return @result;
    }

    . . .
}
```

Notice that we never modify the nodes: the attributes of our AST classes are read-only anyway. Instead, every method builds and returns a new node. The per-node work is done by the `optimize-node` multi-method. For each type of node that contains other nodes, there is a candidate that rebuilds the node from optimised children. Two examples:

```raku-static
multi method optimize-node(AST::ScalarDeclaration $node) {
    return AST::ScalarDeclaration.new(
        variable-name => $node.variable-name,
        value => self.optimize-node($node.value),
    );
}

multi method optimize-node(AST::Condition $node) {
    return AST::Condition.new(
        value => self.optimize-node($node.value),
        statements => self.optimize-list($node.statements),
        antistatements => self.optimize-list($node.antistatements),
    );
}
```

The same pattern repeats for assignments, function calls and definitions, loops, and return statements. Consult the repository for the complete list. The default candidate closes the chain: a node that the optimiser does not know how to improve is returned as it is:

```raku-static
multi method optimize-node(ASTNode $node) {
    return $node;
}
```

Plug the new stage into the main script:

```raku-static
use LinguaOptimizer;
. . .
if $ast {
    note 'OK';
    my $optimizer = LinguaOptimizer.new();
    $evaluator.eval($optimizer.optimize($ast.made));
}
```

At this point, the optimiser does nothing useful: it carefully rebuilds the tree as it was. And that is exactly what we have to verify before optimising anything. So, run the test suite. All tests must pass. This identity transformation is our safety baseline: from now on, after every new optimisation, the suite immediately tells us whether we broke the meaning of some program.

{% include nav.html %}

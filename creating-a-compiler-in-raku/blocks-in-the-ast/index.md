---
title: Blocks in the AST
---

{% include menu.html %}

OK, we can now return to the AST and let the nodes keep arrays of statements when the block in curly braces was seen.

Let us take a closer look at the loop from the example above:

```raku-static
loop n {
    say n;
    say 2 * n;
}
```

In the form of AST, this fragment takes the following shape:

```
AST::Loop.new(
    variable => AST::Variable.new(
        . . .
    ),
    statements => Array[ASTNode].new(
        AST::FunctionCall.new(
            . . .
        ),
        AST::FunctionCall.new(
            . . .
        )
    )
)
```

Again, the abstract nature of the abstract syntax tree is demonstrated here. Although we added the `block` rule in the grammar, there is no trace of it in the tree. The two `say` calls appeared immediately as the elements of the `statements` array attribute within the `AST::Loop` node.

What we need is to loop over the statements in the evaluator:

```raku-static
multi method eval-node(AST::Condition $node) {
    if $node.value.value {
        self.eval-node($_) for $node.statements;
    }
    else {
        self.eval-node($_) for $node.antistatements;
    }
}

multi method eval-node(AST::Loop $node) {
    while %!var{$node.variable.variable-name} > 0 {
        self.eval-node($_) for $node.statements;
        %!var{$node.variable.variable-name}--;
    }
}
```

That’s it! Introducing the `{ }` blocks was a relatively simple task.

{% include nav.html %}

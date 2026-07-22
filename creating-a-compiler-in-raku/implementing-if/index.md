---
title: Implementing if
---

{% include menu.html %}

The language construction we are going to implement first is the prefix `if` clause, demonstrated on the following example:

```raku-static
my flag = 42;
if flag say "Depends";
say "Always";
```

The `if` keyword is followed by a value and a statement. A value is a `value` in sense of our grammar, thus it is either a variable as in the example, or a string, or an expression. A statement can be any statement recognised by the `statement` rule.

Embedding the if clause to the grammar is simple, as we have all statement definitions in one rule:

```raku-static
rule condition {
    'if' <value>
}

rule statement {
    <condition> ? [
        | <statement=variable-declaration>
        | <statement=assignment>
        | <statement=function-call>
    ]
}
```

We have seen earlier that we should not execute the statement before we know if the condition is true. In the AST world, we can pick the statement node out of the tree and place it to an attribute of the condition node. Later, evaluator will decide whether to execute the statement node. So, we need a new kind of AST nodes:

```raku-static
class AST::Condition is ASTNode {
    has ASTNode $.value;
    has ASTNode $.statement;
}
```

In the actions class, the method trigged in response to a parsed statement should now be split into two branches. When there is no if clause, everything remains as is. When there is such a clause, the statement node is not put directly to the tree, but instead, an `AST::Condition` node is inserted in as a proxy:

```raku-static
multi method statement($/ where !$<condition>) {
    $/.make($<statement>.made);
}

multi method statement($/ where $<condition>) {
    $/.make(AST::Condition.new(
        value => $/<condition><value>.made,
        statement => $/<statement>.made,
    ));
}
```

The whole AST for the test program is drawn below.

![diagram](/assets/creating-a-compiler-in-raku/image10.png)

Take a look at the two calls of `say`. The second one (in the right side of the diagram) is located on the top level, as one of the items of the TOP’s `@.statements` array. The first call is a child of the `AST::Condition` node.

The tree is built, and we can evaluate it. The `LinguaEvaluator` class needs a way to react to the `AST::Condition` type of AST nodes. If should check the condition value and pass execution further if needed.

```raku-static
multi method eval-node(AST::Condition $node) {
    if $node.value.value {
        self.eval-node($node.statement);
    }
}
```

That’s all! Test the program with different values of the flag variable and see how the program reacts.

To complete the implementation, add a test in the `t` directory:

```raku-static
my flag = 1;
if flag say "Printed"; ## Printed

flag = 0;
if flag say "Ignored";

say "Done"; ## Done
```

{% include nav.html %}

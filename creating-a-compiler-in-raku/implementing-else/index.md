---
title: Implementing else
---

{% include menu.html %}

A logical next step is to implement the `else` clause. Let us expand the test program:

```raku-static
my flag = 0;
if flag say "Depends" else say "Otherwise";
say "Always";
```

The `else` keyword can only appear if there was an `if` before. In our current grammar, adding the `else` block after the statement alternatives is tricky. It is better to re-organise the grammar and make the `statement` rule only contain statement alternatives, as it was before.

Let us allow the `if`-`else` construct on the top level:

```raku-static
rule TOP {
    [
        | <one-line-comment>
        | <statement=conditional-statement> ';'
        | <statement> ';'
    ]*
}

rule conditional-statement {
    'if' <value> <statement>
    [
        'else' <statement>
    ]?
}

rule statement {
    | <statement=variable-declaration>
    | <statement=assignment>
    | <statement=function-call>
}
```

This grammar will not allow an `else` clause without the `if` prefix, and we could easily refer to the `statement` rule twice inside `conditional-statement`.

Notice that in the `TOP` rule, the new alternative is given an alias, `statement`, which let us keep the same loop in the corresponding action:

```raku-static
method TOP($/) {
    . . .
    for $<statement> -> $statement {
        $top.statements.push($statement.made);
    }
    . . .
}
```

OK, we can now have one or two statements in the conditional construct. The `AST::Condition` node gets a second attribute:

```raku-static
class AST::Condition is ASTNode {
    has ASTNode $.value;
    has ASTNode $.statement;
    has ASTNode $.antistatement;
}
```

The new attribute is filled with either `AST::Null` (if there is no else clause) or with a `statement` node:

```raku-static
method conditional-statement($/) {
    $/.make(AST::Condition.new(
        value => $/<value>.made,
        statement => $/<statement>[0].made,
        antistatement => $/<statement>[1] ?? 
                         $/<statement>[1].made !! AST::Null,
    ));
}
```

The `statement` action can now be reverted to a single method with the trivial body:

```raku-static
method statement($/) {
    $/.make($<statement>.made);
}
```

Finally, evaluator must choose which statement to execute:

```raku-static
multi method eval-node(AST::Condition $node) {
    if $node.value.value {
        self.eval-node($node.statement);
    }
    else {
        self.eval-node($node.antistatement);
    }
}
```

We also have to implement the behaviour of the `AST::Null` node:

```raku-static
multi method eval-node(AST::Null) {
}
```

The `else` keyword is ready and functioning, and a test `t/else.t` must be added to the repository:

```raku-static
if 1 say "A" else say "B"; ## A
if 0 say "A" else say "B"; ## B

my x;
if 1 x = 10 else x = 20;
say x; ## 10

if 0 x = 30 else x = 40;
say x; ## 40
```

{% include nav.html %}

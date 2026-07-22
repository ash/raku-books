---
title: Implementing while
---

{% include menu.html %}

Before the end of the chapter, let us implement the `while` keyword, which is illustrated by the following code:

```raku-static
my n = 1;
while n <= 5 {
    say n;
    n = n + 1
}
```

The loop body is run until the condition stops being true.

Syntactically and semantically the `while` loop is very close to the `loop` cycle we did before. Implementing it is mostly copy-and-paste work.

In the grammar:

```raku-static
rule TOP {
    [
        . . .
        | <statement=loopped-statement>
        | <statement=while-statement>
        . . .
    ]*
}


rule while-statement {
    'while' <value> <block(';')>
}
```

Define a special AST node:

```raku-static
class AST::While is ASTNode {
    has ASTNode $.value;
    has ASTNode @.statements;
}
```

In the actions:

```raku-static
method while-statement($/) {
    $/.make(AST::While.new(
        value => $/<value>.made,
        statements => ($/<block><statement>.map: *.made),
    ));
}
```

In the evaluator:

```raku-static
multi method eval-node(AST::While $node) {
    while $node.value.value {
        self.eval-node($_) for $node.statements;
    }
}
```

The `while` construct is implemented. Add a test and move on to the next chapter.

{% include nav.html %}

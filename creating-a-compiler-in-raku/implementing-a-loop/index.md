---
title: Implementing a loop
---

{% include menu.html %}

Let us implement a loop in our Lingua language. At the moment, let us make it simple and allow only the `loop` keyword, where the counter variable is decremented by the compiler.

```raku-static
my n = 5;
loop n say n;
```

This program prints the values from 5 to 1 and stops.

The syntax of the `loop` clause is similar to the `if` condition we saw in this chapter, and it can be embedded on the top level of the grammar too:

```raku-static
rule TOP {
    [
        | <one-line-comment>
        | <statement=conditional-statement> ';'
        | <statement=loopped-statement> ';'
        | <statement> ';'
    ]*
}
rule loopped-statement {
    'loop' <variable-name> <statement>
}
```

Next, we need a new type of AST node:

```raku-static
class AST::Loop is ASTNode {
    has ASTNode $.variable;
    has ASTNode $.statement;
}
```

The syntax is chosen in such a way that you have to provide the loop with already existing variable. In this case, we do not need to introduce a new loop variable (such as `$_` in Perl). So, in the action method, reference to the variable using a `AST::Variable` node:

```raku-static
method loopped-statement($/) {
    $/.make(AST::Loop.new(
        variable => AST::Variable.new(
            variable-name => ~$/<variable-name>
        ),
        statement => $/<statement>.made,
    ));
}
```

Decreasing the counter is done in the evaluator:

```raku-static
multi method eval-node(AST::Loop $node) {
    while %!var{$node.variable.variable-name} {
        self.eval-node($node.statement);
        %!var{$node.variable.variable-name}--;
    }
}
```

It may be safer to stop the loop when the counter is equal zero or it is negative:

```raku-static
while %!var{$node.variable.variable-name} > 0 {
. . .
```

This allows us to avoid infinite loops when the initial value is not integer, for example:

```raku-static
my n = 5.5;
loop n say n;
```

The test case this time needs more expected output lines than usual:

```raku-static
my n = 3;
loop n say n;
## 3
## 2
## 1
```

{% include nav.html %}

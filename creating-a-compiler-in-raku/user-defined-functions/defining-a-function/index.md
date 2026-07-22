---
title: Defining a function
---

{% include menu.html %}

A definition can appear wherever a statement can, so the `TOP` rule receives one more alternative:

```raku-static
rule TOP {
    [
        | <one-line-comment>
        | <statement=function-definition>
        | <statement=conditional-statement>
        | <statement=loopped-statement>
        | <statement=while-statement>
        | <statement> ';'
    ]*
}
```

The rule itself re-uses two things we already have: the `variable-name` token for both the function name and the parameter names, and the `block` rule for the body:

```raku-static
rule function-definition {
    'func' <function-name=variable-name>
        '(' <parameter=variable-name>* %% ',' ')'
        <block(';')>
}
```

Notice the aliases. The same `variable-name` token parses both kinds of names, but in the match object we want to distinguish the name of the function from the names of its parameters. With the aliases, the former lands in `$<function-name>`, and the latter in the `$<parameter>` array.

The body of a function may contain the `return` instruction, which is a new type of statement:

```raku-static
rule return-statement {
    'return' <value>
}

rule statement {
    | <statement=variable-declaration>
    | <statement=return-statement>
    | <statement=assignment>
    | <statement=function-call>
}
```

Two new AST node types support the additions. A function definition keeps its name, the list of the parameter names, and the statements of the body. A return node keeps the value it has to return:

```raku-static
class AST::FunctionDefinition is ASTNode {
    has Str $.function-name;
    has Str @.parameters;
    has ASTNode @.statements;
}

class AST::Return is ASTNode {
    has ASTNode $.value;
}
```

The action methods build the nodes from the parsed data:

```raku-static
method function-definition($/) {
    $/.make(AST::FunctionDefinition.new(
        function-name => ~$<function-name>,
        parameters => ($<parameter> ?? ($<parameter>.map: ~*) !! ()),
        statements => ($<block><statement>.map: *.made),
    ));
}

method return-statement($/) {
    $/.make(AST::Return.new(
        value => $<value>.made,
    ));
}
```

The check of `$<parameter>` covers the functions that take no arguments at all: in that case, there is nothing to map over.

What should the evaluator do when it meets a function definition? Nothing should be executed, but the definition must be remembered so that future calls can find it. A new hash in the evaluator, `%!func`, plays the same role for functions that `%!var` plays for variables:

```raku-static
class LinguaEvaluator {
    has %.var;
    has %!func;
    . . .
    multi method eval-node(AST::FunctionDefinition $node) {
        %!func{$node.function-name} = $node;
    }
}
```

Run a program that defines a function, and find its complete body stored inside a single node of the tree:

```raku-static
func greet(name) {
    say "Hello, $name!";
}
AST::FunctionDefinition.new(
    function-name => "greet",
    parameters => Array[Str].new("name"),
    statements => Array[ASTNode].new(
        AST::FunctionCall.new(
            function-name => "say",
            . . .
```

The function is parsed and remembered, but there is no way to call it yet.

{% include nav.html %}

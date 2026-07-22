---
title: Calling a function
---

{% include menu.html %}

A call consists of the function name and a list of arguments in parentheses:

```raku-static
rule user-function-call {
    <function-name=variable-name> '(' <value>* %% ',' ')'
}
```

It may appear in two contexts: as a standalone statement and inside an expression. Both the statement rule and the deepest expression level receive the new alternative:

```raku-static
rule statement {
    | <statement=variable-declaration>
    | <statement=return-statement>
    | <statement=user-function-call>
    | <statement=assignment>
    | <statement=function-call>
}

multi rule expr(6) {
    | <number>
    | <function-call>
    | <user-function-call>
    | <variable-name> <index>?
    | '(' <expression> ')'
}
```

The `user-function-call` alternative must be listed before the plain `variable-name`: when the parser sees `add(3, 4)`, we want it to try a function call first. If there are no parentheses after the name, the alternative fails, and the parser falls back to a variable.

The AST node for a call keeps the name, the argument nodes, and a reference to the evaluator, and it computes its value by asking the evaluator to perform the call:

```raku-static
class AST::UserFunctionCall is ASTNode {
    has Str $.function-name;
    has ASTNode @.arguments;
    has $.evaluator;

    method value() {
        return $.evaluator.call-user-function(
            $!function-name, @!arguments);
    }
}
```

The action method offers no surprises:

```raku-static
method user-function-call($/) {
    $/.make(AST::UserFunctionCall.new(
        function-name => ~$<function-name>,
        arguments => ($<value> ?? ($<value>.map: *.made) !! ()),
        evaluator => $!evaluator,
    ));
}
```

The most interesting part is, of course, the call itself. Here is its first version:

```raku-static
method call-user-function($function-name, @arguments) {
    die "Unknown function $function-name"
        unless %!func{$function-name}:exists;

    my $function = %!func{$function-name};
    my @values = @arguments.map: *.value;

    my %saved-vars = %!var;
    %!var = ();
    for ^$function.parameters.elems -> $i {
        %!var{$function.parameters[$i]} = @values[$i];
    }

    my $result = 0;
    self.eval-node($_) for $function.statements;

    %!var = %saved-vars;

    return $result;
}
```

Let us walk through it. First, the function must have been defined earlier; calling an unknown name is a runtime error. Second, the argument values are computed before anything else changes. The arguments may refer to the variables of the caller, so we have to evaluate them while those variables are still in place. Notice that the result is assigned to the `@values` array, which makes the computation eager. A lazy sequence would be computed too late, when the variables have already been replaced.

After that, the current variable storage is saved aside, and a fresh, empty one is created with only the parameters in it. The body is executed by the same `eval-node` machinery that runs the main program. Finally, the saved variables are restored. The method returns 0 for now; the `return` statement is our next topic. A statement-level call also needs a multi-method in the evaluator, which computes the value and throws it away:

```raku-static
multi method eval-node(AST::UserFunctionCall $node) {
    $node.value;
}
```

The first user-defined function in Lingua is ready to run:

```raku-static
func greet(name) {
    say "Hello, $name!";
}
greet("World"); ## Hello, World!
greet("Lingua"); ## Hello, Lingua!
```

{% include nav.html %}

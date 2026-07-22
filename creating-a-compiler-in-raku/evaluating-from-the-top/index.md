---
title: Evaluating from the TOP
---

{% include menu.html %}

The AST tree elements bubble up from the leaf rules and tokens to the TOP rule. Let us take the final AST out of the grammar:

```raku-static
method TOP($/) {
    my $top = AST::TOP.new;
    
    . . .
    
    $/.make($top);
}
```

While we were building the tree, the pair of methods `make` and `made` gave you the way to pass a tree fragment to the parent node. When you use `make` at the `TOP` level, you get the data as the result of the `parse` method:

```raku-static
my $ast = Lingua.parse($code, :actions(LinguaActions.new));
say $ast ?? 'OK' !! error('Error: parse failed');
```

We used the resulting AST in a Boolean context but that’s not the only thing we can do with it. In this chapter, we will work on creating the code to walk along the tree and execute actions that the nodes demand.

In the main script, let’s pass the AST to some `eval` method of the `LinguaEvaluator` class:

```raku-static
use LinguaEvaluator; 

. . .

my $eval = LinguaEvaluator.new();
$eval.eval($ast.made);
```

Let me remind two design ideas from the previous chapter. Any AST node is a child class of an abstract `ASTNode` class, and the top-level node contains everything in an array of statements:

```raku-static
class ASTNode {    
}

class AST::TOP is ASTNode {
    has ASTNode @.statements;
}
```

Executing a program means to run through all the nodes, and thus we start from the top level, taking all the statements one by one:

```raku-static
use LinguaAST;

class LinguaEvaluator {    
    method eval(ASTNode $top) {
        self.eval-node($_) for $top.statements;
    }
}
```

For each statement, the `eval-node` method is called. There is no need to explicitly check the real nature of each statement, as we can let Raku do decide, which method to call for a given statement, using multiple dispatch.

Let us start with the simplest program that declares a variable and initialises it with a value:

```raku-static
my a = 7;
```

There is a single statement in the AST for this program:

```
AST::TOP.new(
    statements => Array[ASTNode].new(
        AST::ScalarDeclaration.new(
            variable-name => "a",
            value => AST::NumberValue.new(
                value => 7
            )
        )
    )
)
```

The type of the node is `AST::ScalarDeclaration`, so there should be a multi-method `eval-node` that takes an argument of that type:

```raku-static
class LinguaEvaluator {
    . . .

    multi method eval-node(AST::ScalarDeclaration $node) {
        . . .
    }
}
```

The job of the method is to create a variable and put a value there. But where do you store the variables now? In the previous chapters, the `%!var` hash was part of the `LinguaActions` class. Now, we don’t need it there anymore and can remove the `hash %!var` declaration from the class.

By the way, that is a good sanity check: there should be no more references to the hash in the `LinguaActions` class. We have one left in the `LinguaActions.string` method where it is used to make string interpolation. Let us remove it from there and keep the action method as simple as possible:

```raku-static
class LinguaActions {
    . . .
    method string($/) {
        $/.make(AST::StringValue.new(value => ~$/[0]));
    }
    . . .
}
```

As there are no data members in the class left, we can get rid of instantiating it and pass a class name instead of an instance to the parser:

```raku-static
my $ast = Lingua.parse($code, :actions(LinguaActions));
```

If everything runs now, then your definition of the `LinguaActions` class is cleaned up completely.

{% include nav.html %}

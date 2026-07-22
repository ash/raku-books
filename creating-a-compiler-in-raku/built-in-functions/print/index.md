---
title: print
---

{% include menu.html %}

Both `print` and `say` print their argument, and we define them similar to their colleagues in Perl: `say` adds a newline character after the output, while `print` does not. If you look at the implementation of the `say` function, you will see that we already created many multi-variants to handle data of different types. It would not be a bright solution to copy-and-paste the code to implement `print`.

First, let us create a separate class for the built-in functions, and move the current implementation of `say` to it. In `LinguaEvaluator`, only a method reacting to the `AST::FunctionCall` node stays, and we pass the `%!var` hash to the next layer.

```raku-static
use LinguaFunctions;

class LinguaEvaluator {
    . . .

    multi method eval-node(AST::FunctionCall $node) {
        LinguaFunctions.call-function(
            $node.function-name, %!var, $node.value);
    }
}
```

Now let us think how to make the body of `say` and `print` as compact as possible. We have to avoid duplicating the code, so let us delegate the main job to multi-methods, and print the newline at a single place:

```raku-static
use LinguaAST;

class LinguaFunctions {
    method call-function(
        Str $function-name where 'say' | 'print',
        %var, $node) {

        print self.gist(%var, $node);
        say '' if $function-name eq 'say';
    }

    . . .
}
```

This method will be called by the evaluator. The real job will be done by the `gist` method.

Notice the filter that is made with the `where` clause. It only allows method calls, where the first argument is a string containing either `'say'` or `'print'`. The vertical bar between the strings creates a junction, the Raku type, formerly known as quantum superposition. A variable of this type can be equal to more than one value. For example:

```raku
my $print-instructions = 'say' | 'print';

for < say print put > -> $function-name {    
    say $function-name eq $print-instructions ?? '✓' !! '✗';
    say $function-name;
}
```

The program tests three names against the same junction. The great thing is that we are using a regular `eq` operator, that you normally use to compare two strings. The output shows which names are allowed:

```
$ raku junction.pl 
✓ say
✓ print
✗ put
```

Back to our printing functions. The entry point for them is ready, so move the rest of the code to the `LinguaFunctions` class with three changes:

add the `%var` argument, as the storage variable is not accessible from this class,

rename the method to `gist`, and

instead of direct printing, `return` the string.

Here is an example of one of such methods:

```raku-static
multi method gist(%var, AST::Variable $value) {
    return %var{$value.variable-name};
}
```

{% include nav.html %}

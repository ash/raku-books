---
title: Interpolating everywhere
---

{% include menu.html %}

Now we have another problem. We only need interpolation for strings, but the `eval-node` method does a generic call of the `value(%!var)` method.

It fails on our test program, as two of the three `AST::ScalarDeclaration` nodes contain references to numbers, not strings, and thus there is no `value` method that takes a hash. If you change the program so that it only uses strings, it begins to work:

```raku-static
my date = "18";
my month = "October";
my year = "2018";
. . .
```

We have to find the way to make the code workable with both strings and numbers but keep it simple. One of the possible solutions is to check the type of the AST node each time it is used in situations when the `value` is taken. Another solution is to define a method that takes the parameter in the `AST::NumberValue` class. Both approaches seem to be quite line-consuming and redundant. Let us instead allow the AST nodes to access the variables directly.

We pass the evaluator object to the instance of `LinguaActions` and keep a reference to it in the node variables. The main program must be modified a bit, a few objects must be created before the actual parsing.

```raku-static
my $evaluator = LinguaEvaluator.new();
my $actions = LinguaActions.new(:evaluator($evaluator));
my $ast = Lingua.parse($code, :actions($actions));

if $ast {
    say 'OK';
    $evaluator.eval($ast.made);
}
else {
    error('Error: parse failed');
}
```

An evaluator object of the `LinguaEvaluator` type is passed to the constructor of the actions class. Notice that we again pass an instance of `LinguaActions` to the parse method, not just the class name.

As we are willing to use the variables outside of the evaluator class, let us declare it public by changing its twigil to a dot.

```raku-static
class LinguaEvaluator {
    has %.var;
    . . .
}
```

(As we saw from the previous section, data methods that would be called public in other programming languages, are a combination of an attribute and a getter method in Raku.)

In the `LinguaActions` class, add a place for keeping the evaluator:

```raku-static
use LinguaEvaluator;
 
class LinguaActions {
    has LinguaEvaluator $.evaluator;
    . . .
}
```

We are passing it to the AST node, but only when creating an `AST::StringValue` node:

```raku-static
$/.make(AST::StringValue.new(
    evaluator => $!evaluator,
    value => ~$match,
    interpolations => @interpolations
));
```

Nodes of other types do not need such reference, as they are not using the data from the evaluator object. So, we only need to change the `AST::StringValue` class:

```raku-static
class AST::StringValue is ASTNode {
    has Str $.value;
    has @.interpolations;
    has $.evaluator;
    . . .
}
```

In this class, we will redefine the default `value` getter with our own method that will interpolate the variables, taking them from the evaluator’s variable storage:

```raku-static
method value() {
    my $s = $!value;

    for @!interpolations.reverse -> $var {
        $s.substr-rw($var[1], $var[2]) = 
            $.evaluator.var{$var[0]};
    }

    . . .
}
```

Now the code is working again, and the string can successfully interpolate both numbers and strings.

{% include nav.html %}

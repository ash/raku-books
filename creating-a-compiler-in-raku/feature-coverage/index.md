---
title: Feature coverage
---

{% include menu.html %}

It is important to create tests for every feature of the language and as many potential use cases as possible. For example, we tested scalar simple assignments such as `i = 10`, but did not try to have an array item on the right side of the equation:

```raku-static
my a[] = 3, 5, 7;
my x = a[1];
say x;
```

Surprisingly, that does not work and produces the error message:

```raku-static
No such method 'value' for invocant of type 'AST::ArrayItem'.
Did you mean 'values'?
  in method eval-node at /Users/ash/lingua/LinguaEvaluator.pm  
  (LinguaEvaluator) line 17
  in method eval at /Users/ash/lingua/LinguaEvaluator.pm
  (LinguaEvaluator) line 9
  in block <unit> at ./lingua line 21
```

The problem is at the line with assignment. The AST tree is built correctly:

```
. . .
AST::ScalarDeclaration.new(
    variable-name => "x",
    value => AST::ArrayItem.new(
      variable-name => "a",
      index => AST::NumberValue.new(
        value => 1
    )
  )
),
. . .
```

Let us check the evaluator (it is clearly referred by the error message, by the way).

```raku-static
multi method eval-node(AST::ScalarDeclaration $node) {
    %!var{$node.variable-name} =
        $node.value ~~ AST::Null ?? 0 !! $node.value.value;
}
```

Everything is fine here, but we do not have the value of the `AST::ArrayItem` node, and thus we have to implement the `value` method in it:

```raku-static
class AST::ArrayItem is ASTNode {
    has Str $.variable-name;
    has ASTNode $.index;
    has $.evaluator;

    method value() {
        return $.evaluator.var{$!variable-name}[$!index.value];
    }
}
```

You also might notice that we don’t have such a method in the `AST::HashItem` class. Add it:

```raku-static
class AST::HashItem is ASTNode {
    has Str $.variable-name;
    has ASTNode $.key;
    has $.evaluator;

    method value() {
        return $.evaluator.var{$!variable-name}{$!key.value};
    }
}
```

Don’t forget to pass an evaluator when building the AST nodes in the actions class (there is more than one place in the `LinguaActions.pm` file):

```raku-static
$/.make(AST::ArrayItem.new(
    . . .
    evaluator => $!evaluator,
));

. . .

$/.make(AST::HashItem.new(
    . . .
    evaluator => $!evaluator,
));
```

Now we can add tests for both arrays and hashes:

```raku-static
my g{} = "a": "b", "c": "d";

say g{"a"}; ## b

my x = g{"a"};
say x; ## b
```

And that (almost) concludes the chapter. All the tests are passing again!

{% include nav.html %}

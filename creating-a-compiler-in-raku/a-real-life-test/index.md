---
title: A real-life test
---

{% include menu.html %}

If you run the loop, you’ll see an error very soon:

```raku-static
5
10
4
Cannot shift from an empty Array[ASTNode]
  in method value at /Users/ash/lingua/LinguaAST.pm    
  (LinguaAST) line 112
```

The first three lines display the expected beginning of the result, but then everything suddenly stopped. The error message helps to understand that that problem is that we were using `shift` to compute the expressions. Within a loop, expressions can be reused, so we should not change them. Let us change all shifts to loops. There are two such places in our code. The first one in the `AST::MathOperations` class:

```raku-static
method value() {
    my $result = @.operands[0].value;

    for 1 .. @.operands.elems - 1 -> $i {
        $result = operation(@.operators[$i - 1], 
                  $result, @.operands[$i].value);
    }

    return $result;
}
```

The second in one of the multi-methods of the evaluator:

```raku-static
multi method eval-node(AST::HashAssignment $node) {
    %!var{$node.variable-name} = Hash.new;
    for 0 .. $node.keys.elems - 1 -> $i {
        %!var{$node.variable-name}.{$node.keys[$i]} =
            $node.values[$i].value;
    }
}
```

The test code is working now. Let us fix the behaviour in the test with similar instructions:

```raku-static
my n = 5;
loop n {
    my n2 = n * n;
    say "n = $n, n2 = $n2";
}
## n = 5, n2 = 25
## n = 4, n2 = 16
## n = 3, n2 = 9
## n = 2, n2 = 4
## n = 1, n2 = 1
```

Don’t forget to test the `if` and `else` blocks, too. The program should be able to execute all the statements from each.

{% include nav.html %}

---
title: Arithmetic operations
---

{% include menu.html %}

It is time to restore the work of our calculator within the compiler, and to implement the solution for the `AST::MathOperations` node. The work we did earlier to re-use the `value` method brings its benefits, and the code is very simple:

```raku-static
class AST::MathOperations is ASTNode {
    . . .
    method value() {
        my $result = @.operands.shift.value;

        while @.operands {
            $result = operation(
                @.operators.shift,
                $result, @.operands.shift.value);
        }

        return $result;
    }
}
```

The actual operation methods are the same which we had in the calculator discussed in Chapter 3. Put them to the `AST::MathOperations` class:

```raku-static
multi sub operation('+', $a, $b) {
    $a + $b
}

multi sub operation('-', $a, $b) {
    $a - $b
}

multi sub operation('*', $a, $b) {
    $a * $b
}

multi sub operation('/', $a, $b) {
    $a / $b
}

multi sub operation('**', $a, $b) {
    $a ** $b
}
```

Having that done, we can simplify the implementation of the `say` function. Previously, we had two multi-variants reacting for either `AST::NumberValue` or `AST::StringValue`. As strings can now interpolate variables themselves, we can just take the value of the node, and there’s no need to distinguish between the types of the nodes:

```raku-static
multi method call-function('say', ASTNode $value) {
    say $value.value;
}
```

Don’t forget to specify the behaviour of the say function for array and hashes. Again, multiple dispatch with the where clause can help here, while the condition becomes a bit wordy:

```raku-static
multi method call-function('say', AST::Variable $value 
    where %!var{$value.variable-name} ~~ Array) {

    say %!var{$value.variable-name}.join(', ');
}

multi method call-function('say', AST::Variable $value 
    where %!var{$value.variable-name} ~~ Hash) {
    
    my $data = %!var{$value.variable-name};
    my @str;
    for $data.keys.sort -> $key {
        @str.push("$key: $data{$key}");
    }
    say @str.join(', ');
}
```

For array and hash items the functions are straightforward:

```
multi method call-function('say', AST::ArrayItem $item) {
    say %!var{$item.variable-name}[$item.index.value];
}

multi method call-function('say', AST::HashItem $item) {
    say %!var{$item.variable-name}{$item.key.value};
}
```

This is the end of this chapter, where we used the AST tree to evaluate the values of its nodes and to run the program in the end. The evaluator class that was built is very compact, as we moved some logic to AST nodes. This let us balance between the pure design and complex code.

{% include nav.html %}

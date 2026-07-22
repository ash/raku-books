---
title: Working with variables
---

{% include menu.html %}

The variables can be stored inside the `LinguaEvaluator` objects, and we can add our data storage to it:

```raku-static
class LinguaEvaluator {
    has %!var;

    . . .
}
```

Use this hash to create the first variable:

```raku-static
multi method eval-node(AST::ScalarDeclaration $node) {
    %!var{$node.variable-name} = 
        $node.value ~~ AST::Null ?? 0 !! $node.value.value;
}
```

All the information for the evaluator is taken from an AST node. In this case it tells us its type (`AST::ScalarDeclaration` is scalar declaration), the name of the variable (`$node.variable-name`) and the content of the variable (`$node.value`). If there’s no value (the `$node.value` attribute contains `AST::Null`), let us store 0 in a variable. Otherwise, just copy the value attribute of the value node.

For debugging, add a couple of `dd` calls to display the AST and the variable storage content:

```raku-static
method eval(ASTNode $top) {
    dd $top;
    self.eval-node($_) for $top.statements;
    dd %!var;
}
```

Now the program can execute our first example and successfully create and initialise the variable:

```raku-static
Hash %!var = {:a("7")}
```

This is all great, so now let the program itself print the value of the variable:

```raku-static
my a = 7;
say a;
```

The AST of this program contains two statements:

```raku-static
AST::TOP.new(
    statements => Array[ASTNode].new(
        AST::ScalarDeclaration.new(
            variable-name => "a",
            value => AST::NumberValue.new(
                value => 7
            )
        ),
        AST::FunctionCall.new(
            function-name => "say",
            value => AST::Variable.new(
                variable-name => "a"
            )
        )
    )
)
```

The second statement is an `AST::FunctionCall` node, keeping the name of the function and in another AST node, in this case the `AST::Variable` node referring to the variable.

The evaluator should now find a multi-method for the function call node. Here it is:

```raku-static
multi method eval-node(AST::FunctionCall $node) {
    self.call-function($node.function-name, $node.value);
}
```

As we expect that there will be more than one function, and their arguments can be of different type, let us implement another set of multi-methods specifically for each function and its arguments. For the given program, we need a `say` function printing a variable:

```raku-static
multi method call-function('say', AST::Variable $value) {
    say %!var{$value.variable-name};
}
```

This method does the final job: it accesses the variable storage and prints the variable to the output.

It is now obvious how printing numbers and strings can be implemented using multi-methods:

```raku-static
multi method call-function('say', AST::NumberValue $value) {
    say $value.value;
}

multi method call-function('say', AST::StringValue $value) {
    say $value.value;
}
```

With these additions, the compiler can handle the following program:

```raku-static
my a = 7;
say a;

say 8;
say "nine";
```

A few other steps can be done to allow other simple operations. We start with a scalar assignment:

```raku-static
a = 10;
```

There’s a variable on the left and a `NumberValue` on the right.

```
AST::ScalarAssignment.new(
    variable-name => "a",
    rhs => AST::NumberValue.new(
        value => 10
    )
)
```

The value is directly accessible via the `$.value` attribute:

```raku-static
multi method eval-node(AST::ScalarAssignment $node) {
    %!var{$node.variable-name} = $node.rhs.value;
}
```

The good part about AST is that its nodes represent quite simple actions. Such as variable declaration or assignment. It means that the implementation is straightforward enough.

Let us teach the evaluator to create array and hashes:

```raku-static
my data[];
my relation{};
```

To implement it, we have to define two more multi-methods for `AST::ArrayDeclaration` and `AST::HashDeclaration`:

```raku-static
multi method eval-node(AST::ArrayDeclaration $node) {
    %!var{$node.variable-name} = Array.new;
}

multi method eval-node(AST::HashDeclaration $node) {
    %!var{$node.variable-name} = Hash.new;
}
```

After it run, the variable storage contains the desired objects:

```raku-static
Hash %!var = {:data($[]), :relation(${})}
```

We also have to think about array and hash initialisation an assignment, but let us first work with single elements:

```raku-static
data[3] = 4;
color{"red"} = "#FF0000";
```

Assignments to the elements of arrays and hashes are as simple as that:

```raku-static
multi method eval-node(AST::ArrayItemAssignment $node) {
    %!var{$node.variable-name}[$node.index] = $node.rhs.value;
}

multi method eval-node(AST::HashItemAssignment $node) {
    %!var{$node.variable-name}{$node.key} = $node.rhs.value;
}
```

The next logical step is to implement array and hash assignments:

```raku-static
data = 7, 8, 9;
color = "white": "#FFFFFF", "black": "#000000";
```

Codewise, this is about two more multi-methods:

```raku-static
multi method eval-node(AST::ArrayAssignment $node) {
    %!var{$node.variable-name} = 
        ($node.elements.map: *.value).Array;
}

multi method eval-node(AST::HashAssignment $node) {
    %!var{$node.variable-name} = Hash.new;
    while $node.keys {
        %!var{$node.variable-name}.{$node.keys.shift} =
            $node.values.shift.value;
    }
}
```

We did not talk about initialization yet, but you will be surprised that the following code already works:

```raku-static
my array[] = 1, 3, 4;
my h{} = "a": 1, "b": 2;
```

This is possible because in the AST tree, array and hash declaration with initialization is presented by the same AST nodes: `AST::ArrayAssignment` and `AST::HashAssignment`.

{% include nav.html %}

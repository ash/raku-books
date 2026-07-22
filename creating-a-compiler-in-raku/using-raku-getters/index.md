---
title: Using Raku getters
---

{% include menu.html %}

In the previous section, we created a separate method to interpolate variables in a string, and we called from the AST node reflecting the call of the `say` function. Imagine now that we want to assign a string to a variable:

```raku-static
my date = 18;
my month = "October";
my year = 2018;

my date = "$date $month $year";
say date;
```

This code will not work, as no interpolation has been made by the evaluator. Instead, an unchanged value will be used. The `eval-node` method for a scalar declaration (and initialisation, too) is using the `value` attribute of a `AST::StringValue` object:

```raku-static
    multi method eval-node(AST::ScalarDeclaration $node) {
        %!var{$node.variable-name} =
            $node.value ~~ AST::Null ??
                           0 !! $node.value.value;
    }
```

It would be great if the string taken from `$node.value.value` already contains a string with interpolated variables. We should not do it statically (at the moment of creation of a `AST::StringValue` node), because the variables may change their values before the string is used.

Fortunately, Raku offers us a mechanism that allow us to change the behaviour of the `value` attribute without changing the code that uses it. In fact, we are already using a getter method with the same name, `value`, which was created by Raku in response to the declaration of the class attribute:

```raku-static
class AST::StringValue . . . {
    has Str $.value;
    . . .
}
```

It is possible to redefine the method with our own implementation:

```raku-static
class AST::StringValue is ASTNode {
    has Str $.value;
    has @.interpolations;

    method value() {
        . . .
        return . . . ;
    }
}
```

Now we can call the interpolation method from within the value method of the `AST::StringValue` class. As it needs access to the variable storage, let us pass it as an argument:

```raku-static
class AST::StringValue is ASTNode {
    has Str $.value;
    has @.interpolations;

    method value(%var) {
        my $s = $!value;

        for @!interpolations.reverse -> $var {
            $s.substr-rw($var[1], $var[2]) = %var{$var[0]};
        }

        . . .
        
        return $s;
    }
}
```

Notice how the `%var` variable is used together with the `$!value` and `@!interpolations` attributes in the method.

In the evaluator, pass the `%!var` storage:

```raku-static
multi method eval-node(AST::ScalarDeclaration $node) {
    %!var{$node.variable-name} =
        $node.value ~~ AST::Null ?? 
                       0 !! $node.value.value(%!var);
}
```

Another part where we can compute the values by redefining the `value` method of an AST node is accessing items of arrays and keys. The following program is an example containing both such cases:

```raku-static
my a[] = 10, 20;
my b{} = "A": "ey", "B": "bee";

my index = 1;
say a[index]; # prints 20

my key = "A";
say b{key}; # prints "ey"
```

Unlike the previous examples, variables are used here in places of array indices and hash keys.

Let us allow variables to compute their values themselves:

```raku-static
class AST::Variable is ASTNode {
    has Str $.variable-name;
    has $.evaluator;

    method value() {
        return $.evaluator.var{$.variable-name};
    }
}
```

Pass a reference of the evaluator to the AST nodes when you build them. For array items:

```raku-static
multi method array-index($/ where $<variable-name>) {
    $/.make(AST::Variable.new(
        variable-name => ~$<variable-name>,
        evaluator => $!evaluator,
    ));
}
```

And for hash key—value pairs:

```raku-static
multi method hash-index($/ where $<variable-name>) {
    $/.make(AST::Variable.new(
        variable-name => ~$<variable-name>,
        evaluator => $!evaluator,
    ));
}
```

Also, don’t forget scalar variables. They can also return their values when they are used in expressions, for example:

```raku-static
multi method expr($/ where $<variable-name> && !$<index>) {
    $/.make(AST::Variable.new(
        variable-name => ~$<variable-name>,
        evaluator => $!evaluator,
    ));
}
```

{% include nav.html %}

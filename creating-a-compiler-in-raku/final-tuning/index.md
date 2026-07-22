---
title: Final tuning
---

{% include menu.html %}

At the end of the chapter, let us make some changes that would make a simpler AST. It was not that important at the early stages, but now we can see a real parse tree. Let us add a shortcut for a variable name in the `value` rule. Currently, the variable name should bubble up from the deepest `expr(4)` rule. We can let the parser see it immediately:

```raku-static
rule value {
    | <variable-name>
    | <expression>
    | <string>
}
```

The action, thus, immediately creates the `AST::Variable` node:

```raku-static
multi method value($/ where $<variable-name>) {
    $/.make(AST::Variable.new(
        variable-name => ~$<variable-name>
    ));
}
```

It is a good idea to extend the variable name with an optional index to allow elements of arrays and hashes in values:

```raku-static
rule value {
    | <variable-name> <index>?
    | <expression>
    | <string>
}
```

We also need to define AST nodes for such data:

```raku-static
class AST::ArrayItem is ASTNode {
    has Str $.variable-name;
    has ASTNode $.index;
}

class AST::HashItem is ASTNode {
    has Str $.variable-name;
    has ASTNode $.key;
}
```

The reason we are using the `ASTNode` type for storing array indices and hash keys is that we expect them to be not only integers or strings, but can be, for example, other variables:

```raku-static
my c{} = "a": 1, "b": 2;
my s = "a";
say c{s};
```

Correct an existing action and add a couple more:

```raku-static
multi method value($/
    where $<variable-name> && !$<index>) {
    $/.make(AST::Variable.new(
        variable-name => ~$<variable-name>
    ));
}

multi method value($/ 
      where $<variable-name> && $<index> && 
            $<index><array-index>) {
    $/.make(AST::ArrayItem.new(
        variable-name => ~$<variable-name>,
        index => $<index>.made
    ));
}

multi method value($/
    where $<variable-name> && $<index> && 
          $<index><hash-index>) {
    $/.make(AST::HashItem.new(
        variable-name => ~$<variable-name>,
        key => $<index>.made 
    ));
}
```

The indices themselves have to become AST nodes now. For each kind of index there are two multi-methods depending on whether we see a variable:

```raku-static
multi method array-index($/ where !$<variable-name>) {
    $/.make(AST::NumberValue.new(
        value => +$<integer>
    ));
}

multi method array-index($/ where $<variable-name>) {
    $/.make(AST::Variable.new(
        variable-name => ~$<variable-name>
    ));
}

multi method hash-index($/ where !$<variable-name>) {
    $/.make($<string>.made);
}

multi method hash-index($/ where $<variable-name>) {
    $/.make(AST::Variable.new(
        variable-name => ~$<variable-name>
    ));
}
```

Another place where we have to worry about variables is a part of expressions that is still managed by the old action:

```raku-static
multi method expr($/ where $<variable-name> && $<index>) {
    if %!var{$<variable-name>} ~~ Array {
        $/.make(%!var{$<variable-name>}[$<index>.made]);
    }
    elsif %!var{$<variable-name>} ~~ Hash {
        $/.make(%!var{$<variable-name>}{$<index>.made});
    }
    else {
        $/.make(%!var{$<variable-name>}.substr(
            $<index>.made, 1));
    }
}
```

This code checks the type of the variable at hand and decides how to work with it. As we already did before in this chapter, we’ll remove all this logic and replace it with one of the AST nodes depending not on the type of the variable but on the grammatical information that is available at this point.

```raku-static
multi method expr($/
    where $<variable-name> && !$<index>) {
    $/.make(AST::Variable.new(
        variable-name => ~$<variable-name>
    ));
}

multi method expr($/
    where $<variable-name> && $<index> && 
          $<index><array-index>) {
    $/.make(AST::ArrayItem.new(
        variable-name => ~$<variable-name>,
        index => $<index>.made
    ));
}

multi method expr($/ 
    where $<variable-name> && $<index> && 
          $<index><hash-index>) {
    $/.make(AST::HashItem.new(
        variable-name => ~$<variable-name>,
        key => $<index>.made.value
    ));
}
```

As a home exercise, try modifying the grammar to exclude the need for `variable` shortcuts (you will also want to join the above code with the `value` methods we’ve seen in this section.

Finally, let us correct the actions to be more careful with the following assignments:

```raku-static
my a;
my b[];

a = 1;
b = 1, 2, 3;
```

Until we do not know the type of the variable, the only method to decide if the variable in the assignment is an array or a scalar is to count the elements on the right side of the equals sign. Here is how we can do that:

```raku-static
multi method assignment($/
    where !$<index> && $<value> && !$<string>) {
    if $<value>.elems == 1 {
        $/.make(AST::ScalarAssignment.new(
            variable-name => ~$<variable-name>,
            rhs => $<value>[0].made
        ));
    }
    else {
        $/.make(AST::ArrayAssignment.new(
            variable-name => ~$<variable-name>,
            elements => ($<value>.map: *.made)
        ));
    }
}
```

And that’s all for now. In this chapter, which is the biggest in the book, we came a long way to transform the compiler from an interpreter to a machine that builds an abstract syntax tree. As you have just seen, we removed some code and mostly had to rely on syntax only. The resulting tree, nevertheless, is a good representation of the program flow, which we will efficiently be using very soon.

{% include nav.html %}

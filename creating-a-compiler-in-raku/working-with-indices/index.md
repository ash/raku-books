---
title: Working with indices
---

{% include menu.html %}

It is important to realise that when we are building the AST, we are not going to evaluate it. It means, for example, that we should not worry about the real content of a variable. Our task is just to put its name in a node attribute. The same counts for accessing elements of arrays and hashes. In AST, we only save the name of the variable and the index of an element or the key if that variable is a hash.

Let us create the classes for the assignments to an array item and to an element of a hash.

```raku-static
class AST::ArrayItemAssignment is ASTNode {
    has Str $.variable-name;
    has Int $.index;
    has ASTNode $.rhs;
}

class AST::HashItemAssignment is ASTNode {
    has Str $.variable-name;
    has Str $.key;
    has ASTNode $.rhs;
}
```

An index of an array is stored in an integer `$.index` field, and the key for a hash is kept in the string `$.key`. In the rest, the nodes look alike.

Emitting AST nodes is also a job that looks similar for both arrays and hashes:

```raku-static
multi method assignment($/ 
    where $<index> && $<index><array-index>) {
    $/.make(AST::ArrayItemAssignment.new(
        variable-name => ~$<variable-name>,
        index => $<index>.made,
        rhs => $<value>[0].made
    ));
}

multi method assignment($/ 
    where $<index> && $<index><hash-index>) {
    $/.make(AST::HashItemAssignment.new(
        variable-name => ~$<variable-name>,
        key => $<index>.made.value,
        rhs => $<value>[0].made
    ));
}
```

Note that using the AST nodes already let us make the assignment quite versatile. For example, our code supports both numbers and strings in the right-hand side of the equation. Take the Lingua example:

```raku-static
my a[];
a[2] = 3;

my b{};
b{"x"} = "y";
```

Its generated AST tree is shown in the next diagram together with the lines of code that the nodes reflect.

![diagram](/assets/creating-a-compiler-in-raku/image7.png)

{% include nav.html %}

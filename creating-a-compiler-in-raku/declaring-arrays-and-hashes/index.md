---
title: Declaring arrays and hashes
---

{% include menu.html %}

For the arrays and hashes, we also have to create nodes that will be responsible for declaring variables of those types. Let us start with arrays:

```raku-static
class AST::ArrayDeclaration is ASTNode {
    has Str $.variable-name;
    has ASTNode @.elements;
}
```

Now, let us change the action. Currently, array declaration immediately creates a record in the `%!var` storage:

```raku-static
multi method array-declaration($/ where !$<value>) {
    %!var{$<variable-name>} = Array.new;
}
```

When we are working with the AST tree, all such actions must be postponed until the compiler walks along the complete tree. For now, the only action is to pass further an `AST::ArrayDeclaration` node:

```raku-static
multi method array-declaration($/ where !$<value>) {
    $/.make(AST::ArrayDeclaration.new(
        variable-name => ~$<variable-name>,
        elements => []
    ));
}
```

The new method just adds an AST node to the tree.

```raku-static
multi method variable-declaration($/ 
    where $<array-declaration>) {
    $/.make($<array-declaration>.made);
}

multi method array-declaration($/ where !$<value>) {                
    $/.make(AST::ArrayDeclaration.new(
        variable-name => ~$<variable-name>,
        elements => []));
}
```

Hashes support requires almost the same code, the obvious difference is the aggregate type of the `elements` attribute.

```raku-static
multi method variable-declaration($/
    where $<hash-declaration>) {
    $/.make($<hash-declaration>.made);
}

multi method hash-declaration($/ where !$<string>) {
    $/.make(AST::HashDeclaration.new(
        variable-name => ~$<variable-name>,
        elements => {}));
}
```

The AST node definition is shown below:

```raku-static
class AST::HashDeclaration is ASTNode {
    has Str $.variable-name;
    has ASTNode %.elements;
}
```

After this change, you may notice three lookalike methods:

```raku-static
multi method variable-declaration($/ 
    where $<scalar-declaration>) {
    $/.make($<scalar-declaration>.made);
}

multi method variable-declaration($/ 
    where $<array-declaration>) {
    $/.make($<array-declaration>.made);
}

multi method variable-declaration($/ 
    where $<hash-declaration>) {
    $/.make($<hash-declaration>.made);
}
```

All three methods can be re-written if you add an alias in the grammar rule:

```raku-static
rule variable-declaration {
    'my' [
        | <declaration=array-declaration>
        | <declaration=hash-declaration>
        | <declaration=scalar-declaration>
    ]
}
```

The match variable now contains two entries, one for the original rule name, the second for the alias:

```raku-static
｢my array[]｣
 declaration => ｢array[]｣
  variable-name => ｢array｣
 array-declaration => ｢array[]｣
  variable-name => ｢array｣
```

Having that, the three actions can merge to a single and simple method that does the job for all the branches of the rule.

```raku-static
multi method variable-declaration($/) {
    $/.make($<declaration>.made);
}
```

{% include nav.html %}

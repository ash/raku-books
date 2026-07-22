---
title: Function calls
---

{% include menu.html %}

Function calls are also drastically simpler in the form of AST, as the node carries only the name of the function and the node containing the argument of the function:

```raku-static
class AST::FunctionCall is ASTNode {
    has Str $.function-name;
    has ASTNode $.value;
}
```

The new action method does not do any real printing or string formatting:

```raku-static
method function-call($/) {
    $/.make(AST::FunctionCall.new(
        function-name => ~$<function-name>,
        value => $<value>.made
    ));
}
```

{% include nav.html %}

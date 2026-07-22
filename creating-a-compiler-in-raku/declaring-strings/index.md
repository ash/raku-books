---
title: Declaring strings
---

{% include menu.html %}

For the string values, let us create a new type of nodes, `AST::StringValue`:

```raku-static
class AST::StringValue is ASTNode {
    has Str $.value;
}
```

We will emit an instance of this class whenever a string is parsed:

```raku-static
method string($a) {
    . . .

    $a.make(AST::StringValue.new(value => $s));
}
```

We will return to strings in the next chapter, because we still have to re-implement variable interpolation.

{% include nav.html %}

---
title: keys
---

{% include menu.html %}

The last built-in function on our list is `keys`. For a hash, it returns the list of its keys. As the internal order of a hash is not guaranteed, let us sort the keys before returning them. Among other things, that makes the function predictable and thus testable:

```raku-static
multi method call-function('keys', %var, AST::Variable $node
    where %var{$node.variable-name} ~~ Hash) {
    return %var{$node.variable-name}.keys.sort.List;
}
```

For an array, the natural counterpart is the list of its indices:

```raku-static
multi method call-function('keys', %var, AST::Variable $node
    where %var{$node.variable-name} ~~ Array) {
    return (0 ..^ %var{$node.variable-name}.elems).List;
}
```

The `..^` operator creates a range that excludes its right end. In other words, for a three-element array, we get the indices 0, 1, and 2.

The function returns a Raku List, and the `say` function does not yet know how to print one nicely. One more `gist` candidate solves that:

```raku-static
multi method gist(%var, ASTNode $value where $value.value ~~ List) {
    return $value.value.join(', ');
}
```

There is one more place where a list can appear: as an argument of another function. What is the length of a list of keys? The generic `len` candidate converts its argument to a string and counts the characters, which is not what anyone expects. A special variant for lists fixes it:

```raku-static
multi method call-function('len', %var, ASTNode $node
    where $node.value ~~ List) {
    return $node.value.elems;
}
```

Now the functions compose nicely, and the test file confirms it:

```raku-static
my h{} = "beta": 2, "alpha": 1, "gamma": 3;
say keys h; ## alpha, beta, gamma
my a[] = 10, 20, 30;
say keys a; ## 0, 1, 2
say len keys h; ## 3
```

{% include nav.html %}

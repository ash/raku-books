---
title: Scalar assignment
---

{% include menu.html %}

As you can see, when building the AST, we have to work with all the rules we’ve built in the previous chapters. Actually, we will need another round in the next chapter, when we will create the code to execute the actions required by the different AST nodes.

For now, let us implement scalar assignment. The AST node for this should contain the name of the variable and something that will be assigned. Let’s call it `$.rhs,` which stands for right-hand side. This object is definitely an `ASTNode` one, but we do not restrict what exactly it hosts. It can be a scalar value or an expression that has to be evaluated first.

```raku-static
class AST::ScalarAssignment is ASTNode {
    has Str $.variable-name;
    has ASTNode $.rhs;
}
```

Unlike the declaration rules, there is only one assignment rule, and we are using its parts to dispatch the action methods call. Here is what needs to be changed to build a scalar assignment node:

```raku-static
multi method assignment($/ where !$<index>) {
    . . .
    else {
        $/.make(AST::ScalarAssignment.new(
            variable-name => ~$<variable-name>,
            rhs => $<value>[0].made));
    }
}
```

To unify passing the node to the statement, we can do the same trick as in the previous section, and add an alias to the rule:

```raku-static
rule statement {
    | <statement=variable-declaration>
    | <statement=assignment>
    | <statement=function-call>
}
```

Now, a single action method can handle all three branches:

```raku-static
method statement($/) {
    $/.make($<statement>.made);
}
```

{% include nav.html %}

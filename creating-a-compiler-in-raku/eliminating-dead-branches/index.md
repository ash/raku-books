---
title: Eliminating dead branches
---

{% include menu.html %}

The third optimisation works on statements rather than expressions. After constant folding, the condition of an `if` statement may turn out to be a literal. In that case, the outcome is known at compile time: only one of the two branches can ever run, and the other one is dead code. The whole `AST::Condition` node can be removed from the tree, and the statements of the surviving branch take its place.

This transformation is different from the previous ones: a single node is replaced with a list of nodes. That is why it lives in `optimize-list`, the method that processes every list of statements in the program: the top level, the bodies of blocks, and the bodies of functions:

```raku-static
method optimize-list(@statements) {
    my @result;
    for @statements -> $statement {
        my $node = self.optimize-node($statement);

        if $node ~~ AST::Condition && $node.value ~~ AST::NumberValue {
            my @branch = $node.value.value
                ?? $node.statements
                !! $node.antistatements;
            @result.append(@branch.grep({ $_ !~~ AST::Null }));
        }
        else {
            @result.push($node);
        }
    }
    return @result;
}
```

The statement is optimised first. This is what folds its condition, if it is foldable. If the condition ends up a number literal, the appropriate branch is spliced into the surrounding list. The `grep` filters out the `AST::Null` that represents a missing `else` branch. Take a program:

```raku-static
if 1 {
    say "always";
}
if 0 {
    say "never";
}
else {
    say "instead";
}
if 2 > 1 say "folded, too";
```

After the optimisation, the dump of the tree contains no `AST::Condition` nodes at all, only three plain function calls, as if the program had been written as:

```raku
say "always";
say "instead";
say "folded, too";
```

What about the loops? A `while` loop with a constant zero condition is dead code, too, and you can eliminate it in exactly the same manner. This is a good exercise to make at home. Be careful with the opposite case, though: `while 1` is an infinite loop, and it must stay in the program. It is not the optimiser’s business to judge it.

We are done; time for the final check:

```
$ ./run-tests
```

```
. . .
--------- Summary ---------
All tests successfully ran.
```

Every passing test means that every optimisation we made preserves the behaviour of every program we have — and this, not the smaller tree, is the most important property of an optimiser.

{% include nav.html %}

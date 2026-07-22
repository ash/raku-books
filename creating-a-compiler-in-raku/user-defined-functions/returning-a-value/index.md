---
title: Returning a value
---

{% include menu.html %}

The `return` statement is parsed and lives in the tree as an `AST::Return` node, but the evaluator does not know about it yet. Think about what has to happen at the moment the program flow reaches `return`. The current function must stop immediately (even if the statement sits deep inside nested blocks), and the value must travel all the way up to the point of the call.

This description surprisingly well matches the behaviour of exceptions. Raku lets us create our own exception class; give it an attribute for the payload:

```raku-static
class X::LinguaReturn is Exception {
    has $.value;
}
```

When the evaluator meets a return node, it computes the value and throws it:

```raku-static
multi method eval-node(AST::Return $node) {
    X::LinguaReturn.new(value => $node.value.value).throw;
}
```

The calling method catches the exception. In Raku, the `CATCH` block is placed inside the block it protects, so wrap the loop over the statements:

```raku-static
my $result = 0;
{
    self.eval-node($_) for $function.statements;

    CATCH {
        when X::LinguaReturn {
            $result = .value;
        }
    }
}
```

The `when` clause matches our exception type and reads the payload from the topic variable. Whatever statements follow the `return` are never executed: the exception has already left the block. A function without an explicit `return` simply finishes the loop and returns the default 0.

Test time!

```raku-static
func add(a, b) {
    return a + b;
}
say add(3, 4); ## 7
my s = add(10, add(1, 2));
say s; ## 13
say add(1, 1) * add(2, 2); ## 8
```

Notice the second call: a function call inside an argument of another call. We did not do anything special to allow this. It works because arguments are values, and function calls are now values, too.

{% include nav.html %}

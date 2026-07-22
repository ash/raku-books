---
title: len
---

{% include menu.html %}

The `len` function should return the length of its argument. In the simplest case, the length of a string is a number of characters, and we can define the following function:

```raku-static
multi method call-function('len', %var, ASTNode $node) {
    say $node.value.chars;
}
```

Test it on the following code:

```raku-static
len "abc";

my x = "abcdef";
len x;
```

The program prints 3 and 6, which is correct, but of course it would be more useful if the `len` function does not print the result immediately but returns it as a value, which we either can print ourselves or save in a variable or use in an expression. Indeed, if it is a function, it is expected to return some value.

Before we make `len` return the result, one small thing has to be fixed. The new method is declared as a multi-method, while the `call-function` method for `say` and `print` was not. Raku does not allow mixing multi and non-multi methods of the same name within one class, so add the `multi` keyword to the printing method, too:

```raku-static
multi method call-function(
    Str $function-name where 'say' | 'print',
    %var, $node) {
    . . .
}
```

Now to the value itself. All the AST nodes that can appear inside expressions (variables, string values, array and hash items) have the `value` method, which is called whenever the data behind the node is needed. So, the most natural way to embed function calls into this system is to give a `value` method to the `AST::FunctionCall` class, too.

Here we run into a naming problem. The class already has an attribute called `value`, which keeps the argument of the function, and Raku has already created a getter method with that name. The name is now needed for more important things, so let us rename the attribute to a more precise `argument`:

```raku-static
class AST::FunctionCall is ASTNode {
    has Str $.function-name;
    has ASTNode $.argument;
}
```

The renaming touches two more files. In the actions class, the node is created with the new attribute name (notice that we also pass a reference to the evaluator, as we did earlier for the nodes that need access to the variable storage):

```raku-static
method function-call($/) {
    $/.make(AST::FunctionCall.new(
        function-name => ~$<function-name>,
        argument => $<value>.made,
        evaluator => $!evaluator,
    ));
}
```

In the evaluator, the method that reacts to a function call statement reads the renamed attribute, and the call itself is moved to a separate method:

```raku-static
method call-function($function-name, $argument) {
    return LinguaFunctions.call-function(
        $function-name, %!var, $argument);
}

multi method eval-node(AST::FunctionCall $node) {
    self.call-function($node.function-name, $node.argument);
}
```

Why not call `LinguaFunctions` directly from the AST node? The LinguaFunctions module already loads LinguaAST, and if LinguaAST loaded LinguaFunctions in its turn, we would get a circular dependency between the modules. Delegating via the evaluator keeps them in a simple one-directional chain. The `value` method of the node is then a one-liner:

```raku-static
class AST::FunctionCall is ASTNode {
    has Str $.function-name;
    has ASTNode $.argument;
    has $.evaluator;

    method value() {
        return $.evaluator.call-function(
            $!function-name, $!argument);
    }
}
```

The last step is to tell the grammar that a function call is a valid part of an expression. There is a single place to change, and it is the deepest level of the `expr` multi-rule:

```raku-static
multi rule expr(6) {
    | <number>
    | <function-call>
    | <variable-name> <index>?
    | '(' <expression> ')'
}
```

The corresponding action method simply passes the node further:

```raku-static
multi method expr($/ where $<function-call>) {
    $/.make($<function-call>.made);
}
```

Finally, replace `say` with `return` in the implementation of `len`:

```raku-static
multi method call-function('len', %var, ASTNode $node) {
    return $node.value.chars;
}
```

Everything is ready. The `len` function can now be used on its own, on the right side of an assignment, and inside bigger expressions. Save the following program in `t/len.t`, and it becomes a part of our test suite:

```raku-static
say len "abc"; ## 3
my s = "abcdef";
say len s; ## 6
my n = len s;
say n; ## 6
say (len s) + 1; ## 7
```

Notice the parentheses in the last line. Without them, the parser reads `len s + 1` as ’the length of `s + 1`’, because a function call consumes the whole expression that follows the function name. Parentheses make the intention explicit.

By the way, what happens to a variable whose name starts with the name of a function, say, a variable called `sayonara`? Nothing bad happens:

```raku-static
my sayonara = 3;
say sayonara + 1; ## 4
```

The `ws` regex, which we defined in the CommentableLanguage grammar in Chapter 5, begins with the `<!ww>` assertion. It forbids matching between two word characters, so the parser cannot cut the word `sayonara` after its first three letters. A test for this case is nevertheless worth adding to the suite.

The length of a string is the number of its characters, but Lingua also has aggregate data types. For arrays and hashes, let `len` return the number of elements. In both cases, the answer comes from Raku’s `elems` method, and the `where` clause selects the proper candidate, as it already does for the `gist` multi-methods:

```raku-static
multi method call-function('len', %var, AST::Variable $node
    where %var{$node.variable-name} ~~ Array | Hash) {
    return %var{$node.variable-name}.elems;
}
```

The junction in the `where` clause covers both aggregate types in one line. Extend the test file to keep the new behaviour fixed:

```raku-static
my a[] = 2, 4, 6;
say len a; ## 3
my h{} = "x": 1, "y": 2;
say len h; ## 2
```

{% include nav.html %}

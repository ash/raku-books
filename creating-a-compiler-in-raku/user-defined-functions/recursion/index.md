---
title: Recursion
---

{% include menu.html %}

The classical demonstration of recursion is the factorial function:

```raku-static
func fact(n) {
    if n <= 1 {
        return 1;
    }
    return n * fact(n - 1);
}
say fact(5);
```

Run it, and instead of 120, you get an error:

```
Error: parse failed
```

The grammar refuses the program, and the reason is the `if` statement inside the body of the function. Remember the `block` rules from Chapter 11: a block contains a list of statements, and the `statement` rule knows nothing about conditional or loop statements. Those are alternatives of the `TOP` rule only. Until now, all our conditions and loops lived at the top level of the program, and the limitation was invisible.

The fix is to teach the block rules the same alternatives that `TOP` has:

```raku-static
multi rule block(';') {
    | '{' ~ '}' [
        [
            | <one-line-comment>
            | <statement=conditional-statement>
            | <statement=loopped-statement>
            | <statement=while-statement>
            | <statement> ';'
        ]* <statement>?
    ]
    | <statement> ';'
}
```

A few things to note here. First, the same change goes into the second multi-variant of the rule, `block()`. Second, the `%%` operator from the previous version is replaced with explicit alternatives: nested constructs bring their own braces and do not want a semicolon, while plain statements still require one. The trailing `<statement>?` keeps the semicolon after the last statement of a block optional, as before. And third, we took the chance to allow one-line comments inside blocks. Now, when the programs are becoming longer than a few lines, the user will definitely want to comment the body of a function.

No changes are needed in the actions: all the alternatives are aliased to `statement`, so they arrive in the same `$<block><statement>` array that the actions already process. Blocks can now contain other blocks, conditions can be nested in loops, loops in conditions, and all of them in functions.

OK, the factorial program works now, and together with it, the whole world of recursive functions opens:

```raku-static
func fact(n) {
    if n <= 1 {
        return 1;
    }
    return n * fact(n - 1);
}
say fact(1); ## 1
say fact(5); ## 120
say fact(10); ## 3628800

func fib(n) {
    if n <= 2 {
        return 1;
    }
    return fib(n - 1) + fib(n - 2);
}
say fib(10); ## 55
```

Both functions call themselves (`fib` even calls itself twice per call), and the local scopes keep every level of the recursion independent. This is a good moment to appreciate how little code was needed: the complete implementation of user-defined functions (grammar, AST nodes, actions, and the evaluator) took us less than a hundred lines.

{% include nav.html %}

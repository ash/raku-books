---
title: Using multi-rules
---

{% include menu.html %}

The three rules, `expression`, `term`, and `factor` are all share the same pattern: a rule that repeats more than one time with an operator in-between. We can unify them by using multi-methods, that are available in Raku classes (and thus, in grammars). Instead of three different tokens `op1`, `op2`, and `op3`, let us create a single name and three alternatives by specifying an integer argument and its value.

```raku-static
multi token op(1) {
    '+' | '-'
}

multi token op(2) {
    '*' | '/'
}

multi token op(3) {
    '**'
}
```

The values 1 to 3 are not important for the grammar itself; for us it indicates operator precedence: the higher the number the higher the precedence.

We also have to update the rules using the tokens:

```raku-static
rule expression {
    <term>+ %% <op(1)>
}

rule term {
    <factor>+ %% <op(2)>
}

rule factor {
    <value>+ %% <op(3)>
}
```

In the actions, we will not see the argument value, and all the names with be a simple `op`:

```raku-static
method expression($/) {
    $/.make(process($<term>, $<op>));
}

method term($/) {
    $/.make(process($<factor>, $<op>));
}

method factor($/) {
    $/.make(process($<value>, $<op>));
}
```

It is clearly seen here that the action methods are the same, so we can reduce the code further, but first try running a test program to confirm that the first part of the transformation works.

Let’s continue and collapse the three rules and three methods to a single rule and its corresponding generic method.

```raku-static
rule expression {
    <expr(1)>
}

multi rule expr(1) {
    <expr(2)>+ %% <op(1)>
}

multi rule expr(2) {
    <expr(3)>+ %% <op(2)>
}

multi rule expr(3) {
    <expr(4)>+ %% <op(3)>
}

multi rule expr(4) {
    | <number>
    | <variable-name>
    | '(' <expression> ')'
}
```

This time, the change is a bit larger. We introduced the new multi-rule `expr` that replaced both `term` and `factor`. To make the `expr` method uniform, the `value` method is replaced with `expr(4)`. This is done to be able to access former value as `expr(4)` from the former factor, which became `expr(3)`. After that the three `expr` alternatives that takes arguments 1, 2, and 3 can be replaced with a generic rule:

```raku-static
multi rule expr($n) {
    <expr($n + 1)>+ %% <op($n)>
}
```

Now the grammar has two alternatives: `expr($n)` and `expr(4)`. When the parser reaches the third level, it will choose a more specific `expr(4)` alternative next, which stops the recursion.

In the actions class, the following two methods remain; they replace the methods expression, term, factor, and value:

```raku-static
method expression($/) {
    $/.make($<expr>.made);
}

method expr($/) {
    if $<number> {
        $/.make($<number>.made);
    }
    elsif $<variable-name> {
        $/.make(%var{$<variable-name>});
    }
    elsif $<expr> {
        $/.make(process($<expr>, $<op>));
    }
    else {
        $/.make($<expression>.made);
    }
}
```

At first, it may seem that we made the grammar and actions less transparent, but if you will need to introduce more operators, you will only have to add the new `op(n)` rules in the grammar and their corresponding `sub`s in the actions class.

{% include nav.html %}

---
title: Statement blocks
---

{% include menu.html %}

Until now, both `if` and `else` constructs could contain only single statements. Of course, if you need more than one statement, you can always add an `if` clause to each of them, but it would be much nicer to implement support of code blocks, which present in many other languages. The goal of this section is to execute the following program with both `if`-`else` and a `loop` blocks:

```raku-static
my c = 0;
if c {
    say "c = $c";
    say "IF block";
}
else {
    say "c = $c";
    say "ELSE block";
}

my n = 5;
loop n {
    say n;
    say 2 * n;
}
```

Let us make a first attempt to replace a `statement` with a newly defined `block`:

```raku-static
rule block {
    | '{' ~ '}' <statement>* %% ';'
    | <statement> ';'
}
```

(The `'{' ~ '}' <r>` construct in Raku is equivalent to `'{' <r> '}'`, but often looks cleaner.)

On a conceptual level, we have to allow code blocks where a `statement` is allowed in the grammar. From a practical perspective, we have to think about semicolons at the end of the statements.

For example, a semicolon is not allowed before the else keyword:

```raku-static
if 1 say "A"; else say "B";
```

The problem is that it is still put after a statement. So, we should distinguish between a statement in the `if` clause with and without the `else` clause.

Also, we should not insist on a semicolon after the closing curly brace:

```raku-static
loop n {
    say n;
    say 2 * n;
};
```

And finally, a semicolon before that brace can be declared optional:

```raku-static
loop n {
    say n;
    say 2 * n
}
```

To satisfy all the conditions listed above, let us instruct the grammar where we expect a semicolon and where it is not needed. We can introduce two alternatives of the `block` rule:

```raku-static
multi rule block() {
    | '{' ~ '}' <statement>* %% ';'
    | <statement>
}

multi rule block(';') {
    | '{' ~ '}' <statement>* %% ';'
    | <statement> ';'
}
```

We avoid adding a new rule name and use its argument to select the one. Now we can rewrite the rules for conditions and while-loops:

```raku-static
rule conditional-statement {
    | 'if' <value> <block()> 'else' <block(';')>
    | 'if' <value> <block(';')>
}

rule loopped-statement {
    'while' <variable-name> <block(';')>
}
```

Notice that in the `conditional-statement` rule it was also possible to use square brackets to extract the common part:

```raku-static
rule conditional-statement {
    'if' <value> [
        | <block()> 'else' <block(';')>
        | <block(';')>
    ]
}
```

You may prefer either; my own personal preference is towards the shorter form where you see both branches one after another:

```raku-static
    | 'if' <value> <block()> 'else' <block(';')>
    | 'if' <value> <block(';')>
```

Finally, adjust the `TOP` rule to remove extra semicolons from there:

```raku-static
rule TOP {
    [
        | <one-line-comment>
        | <statement=conditional-statement>
        | <statement=loopped-statement>
        | <statement> ';'
    ]*
}
```

Now to the actions part. First, let us change the actions for the conditional constructs and use `block`s there:

```raku-static
method conditional-statement($/) {
    $/.make(AST::Condition.new(
        value => $/<value>.made,
        statement => $/<block>[0]<statement>[0].made,
        antistatement => $/<block>[1] ??
            $/<block>[1]<statement>[0].made !! AST::Null,
    ));
}

method loopped-statement($/) {
    $/.make(AST::Loop.new(
        variable => AST::Variable.new(
            variable-name => ~$/<variable-name>
        ),
        statement => $/<block><statement>[0].made,
    ));
}
```

Although the result contains long chains of keys and indices of the match object, such as `$/<block>[1]<statement>[0]`, the transformation is simple and is easy to understand. You can test the program, and it will execute the first statement from each curly block.

The next step is to modify the AST so that it keeps more than one statement where a block is allowed. We have to keep all of them, so let us use arrays instead of scalars:

```raku-static
class AST::Condition is ASTNode {
    has ASTNode $.value;
    has ASTNode @.statements;
    has ASTNode @.antistatements;
}

class AST::Loop is ASTNode {
    has ASTNode $.variable;
    has ASTNode @.statements;
}
```

The corresponding actions should now create the new AST nodes and pass all the statements from the code blocks. In the next fragment we use `map`s to loop over the statements in the match object:

```raku-static
method conditional-statement($/) {
    $/.make(AST::Condition.new(
        value => $/<value>.made,
        statements => ($/<block>[0]<statement>.map: *.made),
        antistatements => $/<block>[1] ?? 
        ($/<block>[1]<statement>.map: *.made) !! (AST::Null),
    ));
}

method loopped-statement($/) {
    $/.make(AST::Loop.new(
        variable => AST::Variable.new(
            variable-name => ~$/<variable-name>
        ),
        statements => ($/<block><statement>.map: *.made),
    ));
}
```

{% include nav.html %}

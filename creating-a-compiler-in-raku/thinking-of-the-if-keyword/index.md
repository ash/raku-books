---
title: Thinking of the if keyword
---

{% include menu.html %}

In the previous section, we implemented a lot of features that can be always executed linearly. It is time to think about conditional statements and user-defined functions. The next small example will demonstrate us that we have to make a big shift before we can continue.

Let us imagine we want to implement the `if` clause that can affect function calls. So, you will be able to disable the action if the condition is false:

```raku-static
my condition = 0;
if condition say "Passed";
```

Update the grammar with an optional condition part:

```raku-static
rule function-call {
    ['if' <variable-name>]? <function-name> <value>
}
```

In the action, check the value of the variable and decide if you proceed with the function call:

```raku-static
method function-call($/) {
    if $<variable-name> {
        my $condition = %!var{$<variable-name>};
        return unless $condition;
    }
    . . .
}
```

Run the program with different values of the `condition` variable, and you’ll see that it behaves as expected: when the variable is zero, the `"Passed"` string is not printed. Set the variable to any non-zero value, and the string is printed.

It seems to be a workable solution, even if you change the syntax and make the `if` keyword to start a postfix clause:

```raku-static
rule function-call {
    <function-name> <value> ['if' <variable-name>]?
}
```

There are no changes in the action needed. The test program looks like this now:

```raku-static
my condition = 0;
say "Passed" if condition;
```

Let us undo the last change and try to generalise the `if` keyword and allow it in variable assignments, so that you can write:

```raku-static
my condition = 0;
if condition say "Passed";

my x = 8;
x = 9;
if condition x = 10;
say x;
```

Of course, it is possible to embed the condition to the assignment rule:

```
rule assignment {
    ['if' <variable-name>]?
    <variable-name> <index>? '='
        [
            | [ <string> ':' <value> ]+ %% ','
            |                <value>+   %% ','
        ]
}
```

There are two difficulties here.

First, we now have two `variable-name` keys in the match object, and we have to refer to them as `$<variable-name>[0]` and `$<variable-name>[1]`. In one of the assignments in the example below, `x = 9`, the variable name lands in the 0th element, while in the second, `if condition x = 10`, it goes to the 1st one. This can easily be solved by using a named capture, for example, or by just looking at the length of the `$<variable-name>` array.

The second problem is that we have more than one `assignment` multi-method, and thus we have to update all of them. This is a vast duplication of the code, and we have to continue doing that for other possible statements where we want to allow an `if` clause.

Let us try to work on a level in the grammar, which is closer to the `TOP` rule:

```raku-static
rule statement {
    | <variable-declaration>
    | [ 'if' <variable-name> ]? <assignment>
    | [ 'if' <variable-name> ]? <function-call>
}
```

The repeated part can be converted to a rule:

```raku-static
rule statement {
    | <variable-declaration>
    | <condition>? <assignment>
    | <condition>? <function-call>
}

rule condition {
    'if' <variable-name>
}
```

All the variants of different assignments (e.g, assigning to a scalar variable, or to an element of an array, or setting a value in a hash) are handled in a single point.

Handling of the condition can be also done in a single place, in the new statement action:

```raku-static
method condition($/) {
    $/.make($<variable-name>.made ?? 1 !! 0);
}

method statement($/) {
    if $<condition> {
        my $condition = $<condition>.made;
        fail unless $condition;
    }
}
```

Looks good but it does not work. The program ignores the condition regardless its value:

```
Passed
10
OK
```

Let us debug this behaviour and embed printing instructions to the methods:

```raku-static
method statement($/) {
    if $<condition> {
        my $condition = $<condition>.made;
        say "test condition = $condition";
        fail unless $condition;
    }
}

multi method assignment($/ where !$<index>) {
    . . .
    else {
        say "assign $<variable-name> to " ~ $<value>[0].made;
        %!var{$<variable-name>} = $<value>[0].made;
    }
}
```

In the output, you will see the sequence in which the methods are called:

```
assign x to 9
assign x to 10
test condition = 0
10
OK
```

All assignments happen before the condition check. We already faced a similar situation in the section Skipping comments of Chapter 4 on the example of a program that did not have a semicolon after the last statement. The whole program did not pass the syntax check, but its last statement was executed.

Here is one of the two problematic lines of code:

```raku-static
if condition x = 10;
```

It is a statement in our language definition. To satisfy the `statement` rule, the parser has to check its alternatives, in this case the matching one is the one involving the `assignment` rule:

```raku-static
rule statement {
    . . .
    | <condition>? <assignment>
    . . .
}
```

Thus, both `condition` and `assignment` must match to make the whole `statement` rule match. As soon as the `assignment` rule matches, its action method is called, and an assignment happens.

Similarly, you can track the calls for the third alternative of the `statement` rule and see that the printing happens before the parser can make use of the `condition` variable, and the action of the `function-call` rule happens earlier than we understand that we should not have to call it, which makes the line

```raku-static
if condition say "Passed";
```

behaves incorrectly.

You can try moving all the code from the actions to the `statement` rule, where the condition is checked, or set some global variables that keep the value of the condition checks, but all those methods are error-prone and make the compiler code spaghetti. There is a better alternative, the AST.

In the next sections, we’ll be working on a set of classes to implement Lingua’s AST needs. All the `AST::*` definitions will be kept in a separate file, LinguaAST.pm, and thus you have to add the `use LinguaAST;` instruction in the LinguaActions.pm file.

{% include nav.html %}

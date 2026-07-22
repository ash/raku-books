---
title: Calculator
---

{% include menu.html %}

When considering language parsers, implementing a calculator is like writing a “Hello, World!” programme. In this section, we will create a grammar for the calculator that can handle the four arithmetical operations and parentheses. The hidden advantage of the calculator example is that you have to teach it to follow the operations priority and nested expressions.

Our calculator grammar will expect the single expression at a top level. The priority of operations will be automatically achieved by the traditional approach to grammar construction, in which the expression consists of terms and factors.

The terms are parts separated by pluses and minuses:

```raku-static
<term>+ %% ['+'|'-']
```

Here, Perl 6’s `%%` symbol is used. You may also rewrite the rule using more traditional quantifiers:

```
<term> [['+'|'-'] <term>]*
```

Each term is, in turn, a list of factors separated by the symbols for multiplication or division:

```raku-static
<factor>+  %% ['*'|'/']
```

```

```

Both terms and factors can contain either a value or a group in parentheses. The group is basically another expression.

```raku-static
rule group {
    '(' <expression> ')'
}
```

```

```

This rule refers to the expression rule and thus can start another recursion loop.

It’s time to introduce the enhancement of the `value` token so that it accepts the floating point values. This task is easy; it only requires creating a regex that matches the number in as many formats as possible. I will skip the negative numbers and the numbers in scientific notation.

```raku-static
token value {
    | \d+['.' \d+]?
    | '.' \d+
}
```

Here is the complete grammar of the calculator:

```raku-static
grammar Calc {
    rule TOP {
        ^ <expression> $
    }
    rule expression {
        | <term>+ %% $<op>=(['+'|'-'])
        | <group>
    }
    rule term {
        <factor>+  %% $<op>=(['*'|'/'])
    }
    rule factor {
        | <value>
        | <group>
    }
    rule group {
        '(' <expression> ')'
    }
    token value {
        | \d+['.' \d+]?
        | '.' \d+
    }
}
```

Note the `$<op>=(...)` construction in some of the rules. This is the named capture. The name simplifies the access to a value via the `$/` variable. In this case, you can reach the value as `$<op>`, and you don’t have to worry about the possible change of the variable name after you update a rule as it happens with the numbered variables `$0`, `$1`, etc.

Now, create the actions for the compiler. At the `TOP` level, the rule returns the calculated value, which it takes from the `ast` field of the `expression`.

```raku-static
class CalcActions {
    method TOP($/) {
        $/.make: $<expression>.ast
    }
    . . .
}
```

The actions of the underlying rules `groups` and `value` are as simple as we’ve just seen.

```raku-static
method group($/) {
    $/.make: $<expression>.ast
}

method value($/) {
    $/.make: +$/
}
```

```

```

The rest of the actions are a bit more complicated. The `factor` action contains two alternative branches, just as the `factor` rule does.

```raku-static
method factor($/) {
    if $<value> {
        $/.make: +$<value>
    }
    else {
        $/.make: $<group>.ast
    }
}
```

```

```

Move on to the `term` action. Here, we have to take care of the list with its variable length. The rule’s regex has the `+` quantifier, which means that it can capture one or more elements. Also, as the rule handles both the multiplication and the division operators, the action must distinguish between the two cases.  The `$<op>` variable contains either the `*` or the `/` character.

This is how the syntax tree looks like for the string with three terms, `3*4*5`:

```
expression => 「3*4*5」
 term => 「3*4*5」
  factor => 「3」
   value => 「3」
  op => 「*」
  factor => 「4」
   value => 「4」
  op => 「*」
 factor => 「5」
  value => 「5」
```

```

```

As you can see, there are `factor` and `op` entries on the top levels. You will see the values as `$<factor>` and `$<op>` inside the actions. At least one `$<factor>` will always be available. The values of the nodes will already be known and available in the `ast` property. Thus, all you need to do is to traverse over the elements of those two arrays and perform either multiplication or division.

```raku-static
method term($/) {
    my $result = $<factor>[0].ast;

    if $<op> {
        my @ops = $<op>.map(~*);
        my @vals = $<factor>[1..*].map(*.ast);

        for 0..@ops.elems - 1 -> $c {
            if @ops[$c] eq '*' {
                $result *= @vals[$c];
            }
            else {
                $result /= @vals[$c];
            }
        }
    }

    $/.make: $result;
}
```

In this code fragment, the star character appears in the new role of a placeholder that tells Perl that it should process the data that it can get at this moment. It sounds weird, but it works perfectly and intuitively.

The `@ops` array with a list of the operation symbols consists of the elements that we got after stringifying the `$<op>`’s value:

```raku-static
my @ops = $<op>.map(~*);
```

```

```

The values themselves will land in the `@vals` array. To ensure that the values of the two arrays, `@vals` and `@ops`, correspond to each other, the slice of `$<factor>` is taken, which starts at the second element:

```raku-static
my @vals = $<factor>[1..*].map(*.ast);
```

```

```

Finally, the `expression` action is either to take the calculated value of `group` or to perform the sequence of additions and subtractions. The algorithm is close to the one of the `term`’s action.

```raku-static
method expression($/) {
    if $<group> {
        $/.make: $<group>.ast
    }
    else {
        my $result = $<term>[0].ast;

        if $<op> {
            my @ops = $<op>.map(~*);
            my @vals = $<term>[1..*].map(*.ast);
            for 0..@ops.elems - 1 -> $c {
                if @ops[$c] eq '+' {
                    $result += @vals[$c];
                }
                else {
                    $result -= @vals[$c];
                }
            }
        }
         $/.make: $result;
    }
}
```

The majority of the code for the calculator is ready. Now, we need to read the string from the user, pass it to the parser, and print the result.

```raku-static
my $calc = Calc.parse(
               @*ARGS[0],
               :actions(CalcActions)
           );
say $calc.ast;
```

```

```

Let’s see if it works.

```
$ perl6 calc.pl '39 + 3.14 * (7 - 18 / (505 - 502)) - .14'
42
```

It does.

```

```

On github.com/ash/lang, you can find the continuation of the code demonstrated in this chapter, which combines both the language translator and the calculator to allow the user write the arithmetical expressions in the variable assignments and the print instructions. Here is an example of what that interpreter can process:

```raku-static

x = 40 + 2;
print x;

y = x - (5/2);
print y;

z = 1 + y * x;
print z;

print 14 - 16/3 + x;
```

{% include nav.html %}

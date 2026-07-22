---
title: 86. Basic calculator
---

{% include menu.html %}

*Create a program that calculates mathematical operations with two operands, for example: 4 + 5.3 or 7.8 / 3.*

In this task, we will only limit the solution for the simplest case with only one operation so that there are no issues with the precedence order or parentheses.

Let’s first make a solution with regexes and then transform it so it uses Raku’s grammars.

```raku-nobrowser
my $expression = "14 * 16.4";
$expression ~~ /
    (<[-\d\.]>+) \s*
    ('+' | '-' | '*' | '/') \s*
    (<[-\d\.]>+)
/;
given $1 {
    when '+' {say $0 + $2}
    when '-' {say $0 - $2}
    when '*' {say $0 * $2}
    when '/' {say $0 / $2};
}
```

The regular expression in this example has three capturing parentheses. The first and the third of them match numbers with an optional minus sign and a floating-point dot. We do not check the number format too strictly to keep the program simple, however.

The construction `<[...]>` is a character class in Raku regexes. It lists accepted characters. In our case, those are the digits represented by `\d`, dots `\.`, and minus `-`. Optional spaces around the operator are matched by `\s*`.

The operator character is an alternative: `'+' | '-' | '*' | '/'`.

After the successful match, the parts of `$expression` appear in the variables `$0`, `$1`, and `$2`. These are the shortcuts for the elements of the match objects: `$/[0]`, `$/[1]`, and `$/[2]`. Each element is also an object of the `Match` type.

The `given` statement chooses one of the `when` branches depending on the value in `$1`. Here, an implicit type conversion happens. First, the match object from `$1` is coerced to a string before comparing it with one of the operator characters. Second, the `$0` and `$1` objects are converted to numbers, which are used in actual calculations. Run the program a few times with different expressions and see how it works.

Now, let us solve the problem differently, using grammars. Here is the grammar:

```raku-static
grammar calc {
    rule TOP {
        <value> <operator> <value> {
            given $<operator> {
                when '+' {say $<value>[0] + $<value>[1]}
                when '-' {say $<value>[0] - $<value>[1]}
                when '*' {say $<value>[0] * $<value>[1]}
                when '/' {say $<value>[0] / $<value>[1]}
            }
        }
    }
    token value {
        '-'? \d+ [ '.' \d+ ]?
    }
    token operator {
        '+' | '-' | '*' | '/'
    }
}
```

And, here is how you use it to parse an expression:

```raku-static
my $expression = "14 * 16.2";
calc.parse($expression); # Prints 226.8
```

The definition of the grammar contains the `TOP` rule and two tokens: `value` and `operator`. When the `parse` method is called, the grammar starts parsing the text, using the `TOP` rule, which says that the text should be a value, followed by the operator symbol, followed by another value.

This time, the regex for the values is a bit smarter to make sure the minus sign can appear only before digits, and the decimal point should be seen only once. Still, there is some room to improve the regex.

When using the grammar rules (such as `TOP`), you don’t need to explicitly care about the optional spaces before parts of the expression. It means that both `'14 * 16.2'` and `'14*16.2'` strings are accepted.

The `TOP` rule has three parts: `<value> <operator> <value>`.

After they all match, the action code block is triggered. It contains a `given`- `when` block, similar to the one used earlier in the solution with regexes.

Now, the string values of the expression parts are taken from the match object, which is treated as a hash. For example, the operator character is located in the `$<operator>` object, which is a shortcut for `$/<operator>`. However, there are two `<value>`s in the `TOP` rule. In this case, the match object contains a list of other objects, which you can access via indices:

```raku
say $<value>[0] + $<value>[1]
```

Again, before using the values, the match objects are converted by Raku to numbers.

{% include nav.html %}

---
title: 85. Balanced parentheses
---

{% include menu.html %}

*Check if the parentheses in a given string are balanced, i. e., whether every opening parenthesis has the corresponding closing one.*

Let us limit the input strings with the strings containing parentheses `()` only and no other kinds of brackets `{}`, `[]`, or `<>`. The text in between contains only letters and spaces. Empty parentheses are not allowed.

Prepare the test suite with different cases—a series of balanced examples and a series of strings with unbalanced parentheses.

```raku-static
my @tests = 'a',         '(a)',      '(a b c)', 'a (b)',
            '(b) a',     '(b (a))',  '( ( c))', 'a(b)c',

            'a (', 'a)', '(a) b c)', 'a b)',    '(b a',
            '((b (a))',  '((c)',     '(((a(((', ')a(';
```

For such a task, the best tool available in Raku is grammars. Here is a simple grammar description that can recursively parse the above examples.

```raku-static
grammar Balanced {
    rule TOP {
        <expression>+
    }
    rule expression {
        | <:alpha>+ <expression>?
        | '(' ~ ')' <expression>
    }
}
```

The `TOP` rule says that the sentence is at least one `expression`. An `expres-` `sion` is either a few letters (`<:alpha>+`) optionally followed by another `ex-` `pression` or an `expression` in parentheses.

Notice the way parentheses are introduced in the `expression` rule:

```
'(' ~ ')' <expression>
```

This syntax allows keeping the opening and closing characters together and is synonymous with the following rule:

```
'(' <expression> ')'
```

Now we can parse the strings from the test suit with the `Balanced` grammar.

```raku-static
for @tests -> $test {
    my $result = Balanced.parse($test);
    printf("%-12s is%s balanced\n",
           $test,
           $result ?? '' !! ' not');
}
```

Depending on the success of parsing a string, the `$result` variable either contains a `Match` object or `Nil`. In the Boolean context, it is either `True` or `False`, and it defines what message is printed.

```
a            is balanced
(a)          is balanced
(a b c)      is balanced
a (b)        is balanced
(b) a        is balanced
(b (a))      is balanced
( ( c))      is balanced
a(b)c        is balanced
a)           is not balanced
(a) b c)     is not balanced
a b)         is not balanced
(b a         is not balanced
((b (a))     is not balanced
((c)         is not balanced
(((a(((      is not balanced
a (          is not balanced
)a(          is not balanced
```

{% include nav.html %}

---
title: Simple parser
---

{% include menu.html %}

The first example of the grammar application is on grammar for tiny language that defines an assignment operation and contains the printing instruction. Here is an example of a programme in this language.

```raku-static
x = 42;
y = x;
print x;
print y;
print 7;
```

Let’s start writing the grammar for the language. First, we have to express the fact that a programme is a sequence of statements separated by a semicolon. Thus, at the top level the grammar looks like this:

```raku-static
grammar Lang {
    rule TOP {
        ^ <statements> $
    }
    rule statements {
        <statement>+ %% ';'
    }
}
```

```

```

Here, `Lang` is the name of the grammar, and `TOP` is the initial rule from which the parsing will be started. The rule’s content is a regex surrounded by with a pair of symbols, `^` and `$`, to tie the rule to the beginning and the end of the text. In other words, the whole programme should match the `TOP` rule. The central part of the rule, `<statements>`, refers to another rule. Rules will ignore all the spaces between their parts. Thus, you may freely add spaces to the grammar definition to make it easily readable.

The second rule explains the meaning of `statements`. The `statements` block is a sequence of separate `statement`s. It should contain at least one `statement`, as the `+` quantifier requires, and the delimiter character is a semicolon. The separator is mentioned after the `%%` symbol. In grammar, this means that you must have the separator character between instructions, but you can omit it after the last one. If there’s only one percent character instead of two, the rule will also require the separator after the last statement.

The next step is to describe the `statement`. At the moment, our language has only two operations: assignment and printing. Each of them accepts either a value or a variable name.

```raku-static
rule statement {
    | <assignment>
    | <printout>
}
```

```

```

The vertical bar separates alternative branches like it does in regular expressions in Perl 5. To make the code a bit better-looking and simplify the maintenance, an extra vertical bar may be added before the first subrule. The following two descriptions are identical:

```raku-static
rule statement {
      <assignment>
    | <printout>
}
rule statement {
    | <assignment>
    | <printout>
}
```

```

```

Then, let us define what do `assignment` and `printout` mean.

```raku-static
rule assignment {
    <identifier> '=' <expression>
}
rule printout {
    'print' <expression>
}
```

```

```

Here, we see literal strings, namely, `'='` and `'print'`. Again, the spaces around them do not affect the rule.

An `expression` matches with either an identifier (which is a variable name in our case) or with a constant value. Thus, an `expression` is either an `identifier` or a `value` with no additional strings.

```raku-static
rule expression {
    | <identifier>
    | <value>
}
```

At this point, we should write the rules for identifiers and values. It is better to use another method, named `token`, for that kind of the grammar bit. In tokens, the spaces matter (except for those that are adjacent to the braces).

An identifier is a sequence of letters:

```raku-static
token identifier {
    <:alpha>+
}
```

```

```

Here, `<:alpha>` is a predefined character class containing all the alphabetical characters.

A value in our example is a sequence of digits, so we limit ourselves to integers only.

```raku-static
token value {
    \d+
}
```

```

```

Our first grammar is complete. It is now possible to use it to parse a text file.

```raku-static
my $parsed = Lang.parsefile('test.lang');
```

```

```

If the file content is already in a variable, you may use the `Lang.parse($str)` method to parse it. (There is more about reading from files in the Appendix.)

If the parsing was successful, that if the file contains a valid programme, the `$parse` variable will contain an object of the `Match` type. It is possible to dump it (`say $parsed`) and see what’s there.

```raku-static
「x = 42;
y = x;
print x;
print y;
print 7;
」
 statements => 「x = 42;
y = x;
print x;
print y;
print 7;
」
  statement => 「x = 42」
   assignment => 「x = 42」
    identifier => 「x」
    expression => 「42」
     value => 「42」
  statement => 「y = x」
   assignment => 「y = x」
    identifier => 「y」
    expression => 「x」
     identifier => 「x」
  statement => 「print x」
   printout => 「print x」
    expression => 「x」
     identifier => 「x」
  statement => 「print y」
   printout => 「print y」
    expression => 「y」
     identifier => 「y」
  statement => 「print 7」
   printout => 「print 7」
    expression => 「7」
     value => 「7」
```

This output corresponds to the sample programme from the beginning of this section. It contains the structure of the parsed programme. The captured parts are displayed in the brackets`「...」`. First, the whole matched text is printed. Indeed, as the `TOP` rule uses the pair of anchors `^ ... $`, and so the whole text should match the rule.

Then, the parse tree is printed. It starts with the `<statements>`, and then the other parts of the grammar are presented in full accordance with what the programme in the file contains. On the next level, you can see the content of both the `identifier` and `value` tokens.

If the programme is grammatically incorrect, the parsing methods will return an empty value `(Any)`. The same will happen if only the initial part of the programme matches the rules.

Here is the whole grammar for your convenience:

```raku-static
grammar Lang {
    rule TOP {
        ^ <statements> $
    }
    rule statements {
        <statement>+ %% ';'
    }
    rule statement {
        | <assignment>
        | <printout>
    }
    rule assignment {
        <identifier> '=' <expression>
    }
    rule printout {
        'print' <expression>
    }
    rule expression {
        | <identifier>
        | <value>
    }
    token identifier {
        <:alpha>+
    }
    token value {
        \d+
    }
}
```

```

```

{% include nav.html %}

---
title: Skipping comments
---

{% include menu.html %}

Comments are a must-have for any programming language, so let’s extend the Lingua grammar to allow comments for humans in our programs.

First, we will implement one-line comments that start with a hash (`#`) character and continue to the end of the line, as shown in the next example:

```raku-static
# Declare a variable
my alpha;
alpha = 100; # Assign a value
```

Our grammar dictates that a program is a set of statements separated by a semicolon.

```raku-static
rule TOP {
    <statement>* %% ';'
}
```

A `statement` is one of the following: variable declaration, assignment, or a function call.

```raku-static
rule statement {
    | <variable-declaration>
    | <assignment>
    | <function-call>
}
```

How can we add rules for comments here? A comment itself can be represented by a rule that matches a hash character followed by any number of non-newline characters:

```raku-static
rule comment {
    '#' \N*
}
```

At first, you may think that comments can be added to the grammar in a simple manner:

```raku-static
rule statement {
    | <comment>
    | <variable-declaration>
    | <assignment>
    | <function-call>
}
```

Unfortunately, that does not work. One rule requires that the comment goes until the end of the line, the other wants a semicolon after it. The possible solution is to admit that the program is not only a list of statements.

```raku-static
rule TOP {
    [
        | <comment>
        | <statement> ';'
    ]*
}
```

Now, the program consists of comments and instructions. The latter ending with a semicolon.

After this change, a semicolon after the last statement at the end of the program became mandatory. This is a tricky moment, let us spend some time to understand it properly.

Take a simple program with three statements:

```raku-static
my a;
a = 10;
say a
```

There’s no semicolon at the end of the program but if you run it you will still see `10` in the output, as if the last instruction is still executed.

In fact, the grammar could not completely parse the input text. You can easily prove that by taking a look at the return value of the `Calculator.parse` method, which is `Nil` for this program. So, the grammar did not confirm the validity of the program, but it still executed the actions while working on parsing it. We can avoid this behaviour by switching to the real AST generation, which we’ll do in the following chapters. Meanwhile, let us update the `translator` so that it reports about the status of parsing:

```raku-static
my $result = Lingua.parse($code, :actions(LinguaActions));
say $result ?? 'OK' !! 'Error';
```

The second type of comments that we are going to allow, are the comments between a pair of character sequences `/*` and `*/`. They can contain both one-line and multi-line comments and may appear at any place of the code where a whitespace is allowed. For example:

```raku-static
my /* inline comment */ a;
# one-line comment
a = 10;

/* multi-line
   comment */
say a;
```

The task seems to be difficult as you cannot control where the user puts their comments. As it was just mentioned, the comment is allowed at any place where a whitespace is allowed. Raku already handles whitespaces for us, so can we ask it to skip the comments too?

Any rule in a grammar implicitly contains a regex for matching whitespaces. For example, take the assignment rule:

```raku-static
rule assignment {
    <variable-name> '=' <value>
}
```

The rule can be replaced with a token with a couple of embedded `ws` regexes:

```raku-static
token assignment {
    <variable-name> <ws> '=' <ws> <value>
}
```

Without `<ws>`, the token would require you not to use spaces around the equals sign.

```raku-static
a=10;
b=20;
```

Adding optional whitespaces let us create more human-readable programs:

```raku-static
a = 10;
b = 20;
```

It is possible to redefine the `ws` regex. By default, it matches any number (including none) of spaces outside of the word:

```raku-static
regex ws {
    <!ww> \s*
}
```

This is a perfect place to define the `/* */` comments. The regex has to allow both whitespaces and any text sequences between the comment delimiters:

```raku-static
regex ws {
    <!ww> [
        | \s*
        | \s* '/*' \s* .*? \s* '*/' \s*
    ]
}
```

It looks ugly because of lots of slashes and stars but it does the job as expected. Notice that you have to allow some spaces both before and after the `/*` and `*/` literals. Also notice that this grammar method is a `regex`, not a `rule` or a `token`.

{% include nav.html %}

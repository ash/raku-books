---
title: Grammar
---

{% include menu.html %}

Now it is time to involve Raku grammars and parse the program. Syntactically, grammars are classes, but they use regexes to describe the behaviour of their methods, which are in its turn called rules and tokens. The first rule which is applied usually has the name `TOP`; it is chosen by Raku as the default starting rule. Grammars are meant to parse some text, so just call the `parse` method on the defined grammar and pass the text to it. All that is demonstrated in our first program:

```raku-local
grammar Lingua {
    rule TOP {
        .*
    }
}

my $code = 'test.lng'.IO.slurp();
my $result = Lingua.parse($code);
say $result;
```

Here, the grammar `Lingua` is defined. It will describe our target language, and currently it only has a single rule, which is the first and the last that is applied to the Lingua code contained in `$code`.

The body of the `TOP` rule is a regex that matches any line: the dot matches any character, and a star quantifier allows any number of repetitions of it. The `TOP` method silently anchors the regex to the beginning and the end of the string, so it actually is equivalent to `^ .* $`.

Run `lingua.pl` again and you’ll see that the parser managed to read all the program. This is what is printed in the console:

```raku-static
｢my x;
x = 42;
say x;
｣
```

Those square angle brackets indicate that this is not a regular string that was printed. In our case, the `$result` variable contains an object of the `Lingua` class.

As you may see from the program in Lingua, its statements are separated by semicolon. To be precise at this point, you have to decide whether the statements are separated by semicolon or they should end with it. The difference is that in the first case, you don’t have to put semicolon after the last statement, for example, at the end of the program. Raku grammars allow to implement both options.

So, the program consists of a number of statements separated by semicolon. In the Raku grammar, you express this in the following way:

```raku-static
rule TOP {
    <statement>* %% ';'
}
```

Now, the `TOP` rule is described using another entity, `statement`. It can be repeated any number of times (including none) and if there are more than one statement, they have to be separated by the `';'` character. If you change the definition and type `%` instead of `%%`, the rule will demand to have semicolons after each statement.

A `statement` itself is another rule, which we can first define to be really vague:

```raku-static
rule statement {
    <-[;]>*
}
```

It will match everything except the semicolon character. Empty statements pass this filter too.

With this change, the translator will now split the statements and emit the following output:

```raku-static
｢my x;
x = 42;
say x;
｣
 statement => ｢my x｣
 statement => ｢x = 42｣
 statement => ｢say x｣
 statement => ｢｣
```

The first block displays the whole text of the input program (it was all matched and consumed) and then the four separate statements. The last statement is empty because the original file contained a newline character after the last non-empty character, and the `statement` rule allows empty statements.

There are three different types of statements in our code. They are variable declaration, assignment, and calling a built-in function. It can be easily expressed by the grammar:

```raku-static
rule statement {
    | <variable-declaration>
    | <assignment>
    | <function-call>
}
```

Vertical bars delimit alternative branches of the rule. Formally, only two bars are required to list three options, but for the sake of making the code beautiful, you may add one more bar so that they form a long vertical line in the code outline. If you do that, the grammar will not add an empty match as the first alternative. By the way, another good side of Raku is that it allows hyphens in the names of the variables and methods, and I prefer `variable-declaration` over `variable_declaration`.

Looking at the test program residing in `test.lng`, we can define the new rules to the grammar:

```raku-static
rule variable-declaration {
    'my' <variable-name>
}

rule assignment {
    <variable-name> '=' <value>
}

rule function-call {
    <function-name> <variable-name>
}
```

Quoted strings such as `'my'` and `'='` match literary with the corresponding syntax items in the target language. The names in angle brackets are references to other rules or tokens that we need to define to complete the grammar. And here we come to our first token:

```raku-static
token variable-name {
    \w+
}
```

It matches a sequence of characters that can form a word (so it includes at least letters, digits and underscores). Also notice that there should be at least one character in the name of a variable.

The main difference between rules and tokens is how Raku deals with whitespaces. Look, for example, at the body of the `variable-declaration` rule:

```raku-static
'my' <variable-name>
```

It matches both of the following texts:

```raku-static
my x
my    x
```

Would you create a token instead of a rule, only `myx` can be matched. As you see, tokens in the grammar are perfect for terminals such as variable names or keywords.

Here’s another example of a token:

```raku-static
token value {
    \d+
}
```

At our first approach, we limit the possible values with non-negative integer numbers only. Later, we will extend the token to include the numbers of other types.

Finally, the token for the function name. There is only one built-in function now, so the rule (it can be a token in this case) is straightforward:

```raku-static
rule function-name {
    'say'
}
```

That’s it. Run the program, and here is what it finds (let me omit the first part of the output that duplicates the whole text of the program):

```raku-static
statement => ｢my x｣
  variable-declaration => ｢my x｣
   variable-name => ｢x｣
 statement => ｢x = 42｣
  assignment => ｢x = 42｣
   variable-name => ｢x｣
   value => ｢42｣
 statement => ｢say x｣
  function-call => ｢say x｣
   function-name => ｢say ｣
   variable-name => ｢x｣
```

The output reflects the structure of the parsed program as the grammar understands it. The indentation helps to see the nested structure and its elements. The right side of each line reveals what part of the source code matched.

For example, the first line of the program, `my x;`, is a statement that contains a variable declaration `my` `x` and the variable name `x`. The semicolon was consumed by the separator of the TOP rule and did not go to the output tree. Similarly, the second statement, `x = 42`, is an assignment of the value `42` to a variable name `x`.

If you examine the output generated for the third line, `say x;`, you’ll see that the function name contains an extra space after the function name: `｢say ｣`. This is easy to fix by making the rule a token:

```raku-static
token function-name {
    'say'
}
```

After this change, the result is cleaner:

```raku-static
statement => ｢say x｣
  function-call => ｢say x｣
   function-name => ｢say｣
   variable-name => ｢x｣
```

{% include nav.html %}

---
title: Actions
---

{% include menu.html %}

The grammars in Perl 6 allow actions in response to the rule or token matching. Actions are code blocks that are executed when the corresponding rule or token is found in the parsed text. Actions receive an object `$/`, where you can see the details of the match. For example, the value of `$<identifier>` will contain an object of the `Match` type with the information about the substring that actually was consumed by the grammar.

```raku-static
rule assignment {
    | <identifier> '=' <value>
          {say "$<identifier>=$<value>"}
    | <identifier> '=' <identifier>
}
```

```

```

If you update the grammar with the action above and run the programme against the same sample file, then you will see the substring `x=42` in the output.

The `Match` objects are converted to strings when they are interpolated in double quotes as in the given example: `"$<identifier>=$<value>"`. To use the text value from outside the quoted string, you should make an explicit typecast:

```raku-static
rule assignment {
    | <identifier> '=' <value>
          {%var{~$<identifier>} = +$<value>}
    | <identifier> '=' <identifier>
}
```

```

```

So far, we’ve got an action for assigning a value to a variable and can process the first line of the file. The variable storage will contain the pair `{x => 42}`.

In the second alternative of the `assignment` rule, the `<identifier>` name is mentioned twice; that is why you can reference it as to an array element of `$<identifier>`.

```raku-static
rule assignment {
    | <identifier> '=' <value>
      {
          %var{~$<identifier>} = +$<value>
      }
    | <identifier> '=' <identifier>
      {
          %var{~$<identifier>[0]} =
          %var{~$<identifier>[1]}
      }
}
```

```

```

This addition to the code makes it possible to parse an assignment with two variables: `y = x`. The `%var` hash will contain both values: `{x => 42, y => 42}`.

Alternatively, capturing parentheses may be used. In this case, to access the captured substring, use special variables, such as `$0`:

```raku-static
rule assignment {
    | (<identifier>) '=' (<value>)
      {
           %var{$0} = +$1
      }
    | (<identifier>) '=' (<identifier>)
      {
           %var{$0} = %var{$1}
      }
}
```

```

```

Here, the unary `~` is no longer required when the variable is used as a hash key, but the unary `+` before `$1` is still needed to convert the `Match` object to a number.

Similarly, create the actions for printing.

```raku-static
rule printout {
    | 'print' <value>
      {
          say +$<value>
      }
    | 'print' <identifier>
      {
          say %var{$<identifier>}
      }
}
```

```

```

Now, the grammar is able to do all the actions required by the language design, and it will print the requested values:

```
42
42
7
```

```

```

As soon as we used capturing parentheses in the rules, the parse tree will contain entries named as `0` and `1`, together with the named strings, such as `identifier`. You can clearly see it when parsing the `y = x` string:

```
statement => 「y = x」
 assignment => 「y = x」
  0 => 「y」
   identifier => 「y」
  1 => 「x」
   identifier => 「x」
```

```

```

An updated parser looks like this:

```raku-static
my %var;

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
        | (<identifier>) '=' (<value>)
          {
              %var{$0} = +$1
          }
        | (<identifier>) '=' (<identifier>)
          {
              %var{$0} = %var{$1}
          }
    }
    rule printout {
        | 'print' <value>
          {
              say +$<value>
          }
        | 'print' <identifier>
          {
              say %var{$<identifier>}
          }
    }
```

```raku-static
    token identifier {
        <:alpha>+
    }
    token value {
        \d+
    }
}

Lang.parsefile('test.lang');
```

```

```

For convenience, it is possible to put the code of actions in a separate class. This helps a lot when the actions are more complex and contain more than one or two lines of code.

To create an external action, create a class, which will later be referenced via the `:actions` parameter upon the call of the `parse` or `parsefile` methods of the grammar. As with built-in actions, the actions in an external class receive the `$/` object of the `Match` type.

First, we will train on a small isolated example and then return to our custom language parser.

```raku
grammar G {
    rule TOP {^ \d+ $}
}

class A {
    method TOP($/) {say ~$/}
}

G.parse("42", :actions(A));
```

Both the grammar `G` and the action class `A` have a method called `TOP`. The common name connects the action with the corresponding rule. When the grammar parses the provided test string and consumes the value of `42` by the `^ \d $` rule, the `A::TOP` action is triggered, and the `$/` argument is passed to it, which is immediately printed.

{% include nav.html %}

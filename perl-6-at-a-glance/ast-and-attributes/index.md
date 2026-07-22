---
title: AST and attributes
---

{% include menu.html %}

Now, we are ready to simplify the grammar again after we split the `assignment` and `printout` rules into two alternatives each. The difficulty was that without the split, it was not possible to understand which branch had been triggered. You either needed to read the value from the `value` token or get the name of the variable from the `identifier` token and look it up in the variable storage.

Perl 6’s grammars offer a great mechanism that is common in language parsing theory, the abstract syntax tree, shortened as AST.

First of all, update the rules and remove the alternatives from some of them. The only rule containing two branches is the `expression` rule.

```raku-static
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
```

```

```

The syntax tree that is built during the parse phase can contain the results of the calculations in the previous steps. The `Match` object has a field `ast`, dedicated especially to keep the calculated values on each node. It is possible to simply read the value to get the result of the previously completed actions. The tree is called abstract because how the value is calculated is not very important. What is important is that when the action is triggered, you have a single place with the result you need to complete an action.

The action can save its own result (and thus pass it further on the tree) by calling the `$/.make` method. The data you save there are accessible via the `made` field, which has the synonym `ast`.

Let’s fill the attribute of the syntax tree for the `identifier` and `value` tokens. The match with an identifier produces the variable name; when the value is found, the action generates a number. Here are the methods of the actions’ class.

```raku-static
method identifier($/) {
    $/.make(~$0);
}
method value($/) {
    $/.make(+$0);
}
```

```

```

Move one step higher, where we build the value of the expression. It can be either a variable value or an integer.

As the `expression` rule has two alternatives, the first task will be to understand which one matches. For that, check the presence of the corresponding fields in the `$/` object.

(If you use the recommended variable name `$/` in the signature of the action method, you may access its fields differently. The full syntax is `$/<identifier>`, but there is an alternative version `$<identifier>`.)

The two branches of the expression method behave differently. For a number, it extracts the value directly from the captured substring. For a variable, it gets the value from the `%var` hash. In both cases, the result is stored in the AST using the `make` method.

```raku-static
method expression($/) {
    if $<identifier> {
        $/.make(%var{$<identifier>});
    }
    else {
        $/.make(+$<value>);
    }
}
```

```

```

To use the variables that are not yet defined, we can add the defined-or operator to initialise the variable with the zero value.

```raku-static
$/.make(%var{$<identifier>} // 0);
```

```

```

Now, the expression will have a value attributed to it, but the source of the value is not known anymore. It can be a variable value or a constant from the file. This makes the `assignment` and `printout` actions simpler:

```raku-static
method printout($/) {
    say $<expression>.ast;
}
```

```

```

All you need for printing the value is to get it from the `ast` field.

For the `assignment`, it is a bit more complex but can still be written in a single line.

```raku-static
method assignment($/) {
    %var{$<identifier>} = $<expression>.made;
}
```

```

```

The method gets the `$/` object and uses the values of its `identifier` and `expression` elements. The first one is converted to the string and becomes the key of the `%var` hash. From the second one, we get the value by fetching the `made` attribute.

Finally, let us stop using the global variable storage and move the hash into the action class (we don’t need it in the grammar itself). It thus will be declared as `has %!var;` and used as a private key variable in the body of the actions: `%!var{...}`.

After this change, it is important to create an instance of the actions class before paring it with a grammar:

```raku-static
Lang.parsefile(
    'test.lang',
    :actions(LangActions.new())
);
```

```

```

Here is the complete code of the parser with actions.

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
        (<:alpha>+)
    }
    token value {
        (\d+)
    }
}
```

```raku-static
class LangActions {
    has %var;

    method assignment($/) {
        %!var{$<identifier>} = $<expression>.made;
    }
    method printout($/) {
        say $<expression>.ast;
    }
    method expression($/) {
        if $<identifier> {
            $/.make(%!var{$<identifier>} // 0);
        }
        else {
            $/.make(+$<value>);
        }
    }
    method identifier($/) {
        $/.make(~$0);
    }
    method value($/) {
        $/.make(+$0);
    }
}

Lang.parsefile(
    'test.lang',
    :actions(LangActions.new())
);
```

{% include nav.html %}

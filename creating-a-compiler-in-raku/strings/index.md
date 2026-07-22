---
title: Strings
---

{% include menu.html %}

The first goal is to allow strings in double quotes to appear in variable assignment (or initialisation) and in function calls:

```raku-static
my str = "Hello, World";
say str;

say "Hello indeed";
```

In both cases, the grammar expects an expression:

```raku-static
rule variable-declaration {
    'my' <variable-name> [ '=' <expression> ]?
}

rule function-call {
    <function-name> <expression>
}
```

So, the simplest solution may be adding a string as a variant of an `expression` at the same level where a number may appear:

```raku-static
multi rule expr(4) {
    | <number>
    | <string>
    | <variable-name>
    | '(' <expression> ')'
}
```

Add a branch to the action, too:

```raku-static
method expr($/) {
    if $<number> {
        $/.make($<number>.made);
    }
    elsif $<string> {
        $/.make($<string>.made);
    }

    . . .
}
```

The string itself is defined as a character sequence between double quotes:

```raku-static
rule string {
    '"' .*? '"'
}
```

Its AST attribute is simply a stringified match object:

```raku-static
method string($/) {
    $/.make(~$/)
}
```

That was a low-hanging fruit, but there are two problems with this approach. First, the quotes become a part of a string. Second, if the user put a string in an arithmetic expression (e.g., `"Hello" + "World"`), a compiler fails with an exception.

The first issue is easy to resolve: make a capturing group and access it as [0] in the action:

```raku-static
rule string {
    '"' ( <-["]>* ) '"'
}

. . .

method string($/) {
    $/.make(~$/[0]);
}
```

By the way notice that we are also starting to change the regex for the string. It can now contain any character except the double quote. We will need more of that kind soon.

The second problem is also solvable, but with a larger rebuilding of the grammar. Let us return the `value` rule but this time it can be either an arithmetic expression or a string:

```raku-static
grammar Lingua is CommentableLanguage does Number {
    . . .

    rule variable-declaration {
        'my' <variable-name> [ '=' <value> ]?
    }

    rule assignment {
        <variable-name> '=' <value>
    }

    rule function-call {
        <function-name> <value>
    }

    rule value {
        | <expression>
        | <string>
    }

    . . .
}
```

So, a `string` (as a form of `value`) is expected in the assignments and in function calls.

In the actions, similar changes are made. We work with values instead of expressions:

```raku-static
class LinguaActions {
    has %!var;

    method variable-declaration($/) {
        %!var{$<variable-name>} = 
            $<value> ?? $<value>.made !! 0;
    }

    method assignment($/) {
        %!var{~$<variable-name>} = $<value>.made;
    }

    method function-call($/) {
        say $<value>.made;
    }

    . . .

    method value($/) {
        if $<expression> {
            $/.make($<expression>.made);
        }
        elsif $<string> {
            $/.make($<string>.made);
        }
    }

    . . .
}
```

The result is exactly what was needed. Normal strings are parsed and understood, while an attempt to use them with numbers or in an expression leads to a parse error.

{% include nav.html %}

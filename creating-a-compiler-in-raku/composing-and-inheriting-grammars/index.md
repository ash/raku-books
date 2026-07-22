---
title: Composing and inheriting grammars
---

{% include menu.html %}

In the Lingua language, we allow one-line comments that start with the `#` character, and inline and multi-line comments between `/*` and `*/`. Such comments are used in other programming languages too, and it may be useful to extract the rules for comment parsing out of the language grammar and put it in a separate class. This also makes the main language grammar smaller and more transparent.

Let’s recap the fragments of the existing `Lingua` grammar that handle comments:

```raku-static
grammar Lingua {
    rule TOP {
        [
            | <comment>
            | <statement> ';'
        ]*
    }

    rule comment {
        '#' \N*
    }

    regex ws {
        <!ww> [
            | \s*
            | \s* '/*' \s* .*? \s* '*/' \s*
        ]
    }

    . . .
}
```

Most of these can go to a separate grammar class. We also will make it a bit wordy to clearly distinguish between the two types of comments.

```raku-static
grammar CommentableLanguage {
    regex ws {
        <!ww> [
            | \s*
            | \s* <inline-comment> \s*
        ]
    }

    regex inline-comment {
        '/*' \s* .*? \s* '*/'
    }

    rule one-line-comment {
        '#' \N*
    }
}
```

The `CommentableLanguage` grammar only knows about what to do with comments, but as it now resides in a separate class, it can be a base for another language definition. In our case, `Lingua` can be derived from it:

```raku-static
use CommentableLanguage;

grammar Lingua is CommentableLanguage {
    . . .
}
```

The `use` statement is required if you place the `CommentableLanguage` class in a separate file.

In `Lingua`, the only change is required now is to use a proper name for the one-line comment in the main code:

```raku-static
rule TOP {
    [
        | <one-line-comment>
        | <statement> ';'
    ]*
}
```

All the rest is done automatically. For instance, the default `ws` regex from the Raku Grammar class is now replaced with `ws` from `CommentableLanguage`.

We can make another simplification of the main grammar by extracting the part, which is responsible for parsing numbers. As with comments, that parts is more general thing and can be placed in a separate class too. In this case, though, it is better to make it a role and also save it in a separate file.

```raku-static
role Number {
    token number {
        <sign>? [
            | <integer>
            | <floating-point>
        ] <exponent>?
    }

    token sign {
        <[+-]>
    }

    token exp {
        <[eE]>
    }

    token integer {
        \d+
    }

    token floating-point {
        <integer>? ['.' <integer>]
    }

    token exponent {
        <exp> <sign>? <integer>
    }
}
```

Later, if needed, you can easily modify the `Number` role to allow other types of numbers in the program. To append it to the `Lingua` grammar, use the `does` keyword:

```raku-static
use CommentableLanguage;
use Number;

grammar Lingua is CommentableLanguage does Number {
    . . .
}
```

{% include nav.html %}

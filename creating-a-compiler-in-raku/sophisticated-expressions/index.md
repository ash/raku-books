---
title: Sophisticated expressions
---

{% include menu.html %}

The next step we can easily do is to merge the `Calculator` grammar into the language definition. Let’s rename an existing `value` method to `number`, and the language grammar will use the `value` that was defined in `Calculator`.

```raku-static
grammar Lingua {
    . . .

    rule value {
        | <number>
        | '(' <expression> ')'
    }

    rule expression {
        <term>* %% <op1>
    }

    token number {
        <sign>? [
            | <integer>
            | <floating-point>
        ] <exponent>?
    }

   . . .
}
```

The `expression` rule here is the former `TOP` rule of the `Calculator` grammar. Update the actions class symmetrically:

```raku-static
class LinguaActions {
    . . .

    method value($/) {
        $/.make($<number> ??
            $<number>.made !! $<exression>.made);
    }

    method expression($/) {
        $/.make(process($<term>, $<op1>));
    }

    method number($/) {
        $/.make(+$/);
    }
}
```

After this, any number in the program can be presented by an expression of arbitrary complexity. The only place in our current grammar where a number was used is `assignment`. We can replace the right-hand side of it to the `expression`.

In the grammar:

```raku-static
rule assignment {
    <variable-name> '=' <expression>
}
```

In the actions class:

```raku-static
method assignment($/) {
    %var{~$<variable-name>} = $<expression>.made;
}

method value($/) {
    $/.make($<number> ??
        $<number>.made !! $<expression>.made);
}
```

Change the test program and include a few expressions there. Here is my example:

```raku-static
my pi;
pi = 22/7 - 0.001265; # very rough approximation
say pi;

my x;
x = 2 * (3 + 4);
say x; # prints 14
```

Don’t forget that we can also use comments in the code!

{% include nav.html %}

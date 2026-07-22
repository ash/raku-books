---
title: String interpolation
---

{% include menu.html %}

Let us take the program with string interpolation:

```raku-static
my alpha = 54;
say "The value of α is $alpha.";
```

If you run it, the string will be printed as-is, with no interpolation of the variable. So, we have to return the code that does that to our compiler.

The problem is that the `AST::StringValue` only contains a string itself, and to make a substitution, we need to parse the string again to find all mentioned variables. This is not very efficient, and it is better to store the information about the variables immediately in the parser. Let us remind the grammar token that describes strings:

```raku-static
token string {
    '"' ( [
            | <-["\\$]>+
            | '\\"'
            | '\\\\'
            | '\\$'
            | '$' <variable-name>
            ]* )
    '"'
}
```

Variable names land in the match object. Let us reserve the space for them in the AST node:

```raku-static
class AST::StringValue is ASTNode {
    has Str $.value;
    has @.interpolations;
}
```

In the action, make some simple calculations to compute the name of the variable and its position in a string:

```raku-static
method string($/) {
    my $match = $/[0];

    my @interpolations;
    push @interpolations, [
            .Str,
            .from - $match.from - 1,
            .pos - .from + 1,
        ] for $match<variable-name>;

    $/.make(AST::StringValue.new(
        value => ~$match,
        interpolations => @interpolations
    ));
}
```

Finally, in the `LinguaEvaluator` class, the string can be processed to substitute the variables:

```raku-static
multi method call-function('say', AST::StringValue $value) {
    say self.interpolate($value);
}

method interpolate(AST::StringValue $str) {
    my $s = $str.value;

    for $str.interpolations.reverse -> $var {
        $s.substr-rw($var[1], $var[2]) = %!var{$var[0]};
    }

    $s ~~ s:g/\\\"/"/;
    $s ~~ s:g/\\\\/\\/;
    $s ~~ s:g/\\\$/\$/;

    return $s;
}
```

You may optimize the code and move the three substitutions to the `LinguaActions` class, but it is important to realise that variable interpolation has to happen every time the string is accessed, because the value of the variables may change between the calls, as shown in the next example:

```raku-static
my alpha = 54;
say "The value of α is $alpha.";

my beta;
beta = 200;
alpha = 100;
say "And now it is $alpha (β = $beta).";
```

{% include nav.html %}

---
title: Variable interpolation
---

{% include menu.html %}

As in any Perl, we want variables being interpolated if they appear in a string in Lingua. Let us use the following syntax: to interpolate a variable, use its name preceded by a dollar sign, as shown in the example below:

```raku-static
my name = "John";
say "Hello, $name!";
```

If so, then a literal dollar has to be escaped if needed:

```raku
say "5\$";
```

Introduce the new escape sequence in the `string` token together with a new alternative starting with a `$`:

```raku-static
token string {
    . . .
            | '\\$'
            | '$' <variable-name>
    . . .
}
```

The variable name itself is parsed by another token, `variable-name`.

When the parser sees an interpolation candidate in a string, it creates an array in the match object with the list of all variable names (even if there is only one). These names can be read from `$a[0]<variable-name>`. The next step is to replace all such occurrences with the content of the variables.

```raku-static
method string($a) {
    my $s = ~$a[0];

    for $a[0]<variable-name>.reverse -> $var {
        $s.substr-rw($var.from - $a.from - 2,
                     $var.pos - $var.from + 1) = %!var{$var};
    }

    . . .
}
```

The loop needs some comments. The `$a` container hosts a Match object that keeps a reference to the whole input string, not just the part saved in `$s` but the whole program that is being parsed. Its `from` and `pos` attributes show the edges of the string in hand (`Hello, $name!` in our example).

The `$var` is another Match object, describing the position of a variable name in the source text. An in-place replacement using the `substr-rw` method replaces the variable name together with the preceding dollar character with the value of the variable.

To make the calculation of the starting and ending positions of the interpolated variable names, we scan the string from right to left (see the `reverse` method in the loop).

Now it is possible to have more than one interpolated variable in a string:

```raku-static
my name = "John";
my another_name = "Carla";
say "Hello, $name and $another_name!";
```

{% include nav.html %}

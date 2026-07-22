---
title: Accessing array elements
---

{% include menu.html %}

The next goal is to start using individual array items, for example, as shown in the next fragment:

```raku-static
say data[0];
say data[1];

my n = data[0] * data[1];
say n;
```

Our current actions class already supports indexing strings, and that’s the exact place which we have to extend:

```raku-static
multi method expr($/ where $<variable-name> && $<integer>) {
    if %!var{$<variable-name>} ~~ Array {
        $/.make(%!var{$<variable-name>}[+$<integer>]);
    }
    else {
        $/.make(%!var{$<variable-name>}.substr(
            +$<integer>, 1));
    }
}
```

The method checks the type of the variable stored in the `%!var` hash, and if it is an array, returns the requested element. The other branch works with strings as it did before.

The grammar can be simplified once again by extracting the sequence representing an array (and string) index to a separate rule:

```raku-static
rule index {
    '[' <integer> ']'
}
```

Use the new rule in assignment and when you take the value:

```raku-static
rule assignment {
    <variable-name> <index>? '=' <value>
}

. . .

multi rule expr(4) {
    | <number>
    | <variable-name> <index>?
    | '(' <expression> ')'
}
```

If you ever will want to change the syntax of indexes, there’s a single place to do that, the `index` rule.

The actions must be adapted too. An index’s attribute is an integer value:

```raku-static
method index($/) {
    $/.make(+$<integer>);
}
```

And thus you should use `$<index>.made` to get it in other methods:

```raku-static
multi method assignment($/ where $<index>) {
    %!var{~$<variable-name>}[$<index>.made] = $<value>.made;
}

multi method assignment($/ where !$<index>) {
    %!var{~$<variable-name>} = $<value>.made;
}

. . .

multi method expr($/ where $<variable-name> && $<index>) {
    if %!var{$<variable-name>} ~~ Array {
        $/.make(%!var{$<variable-name>}[$<index>.made]);
    }
    else {
        $/.make(%!var{$<variable-name>}.substr(
            $<index>.made, 1));
    }
}

multi method expr($/ where $<variable-name> && !$<index>) {
    $/.make(%!var{$<variable-name>});
}
```

Once again, the `!$<index>` is used in the where clause to make the code more readable, while the multi-method can be correctly dispatched without it.

{% include nav.html %}

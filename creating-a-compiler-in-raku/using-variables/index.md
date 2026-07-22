---
title: Using variables
---

{% include menu.html %}

In our expressions, only numbers can be used. It would be much handier if we can use variables there too. To achieve that, a small change to the grammar is needed. In terms of the grammar rules, to have a variable in an expression means to allow variable names in it:

```raku-static
rule value {
    | <number>
    | <variable-name>
    | '(' <expression> ')'
}
```

There is no `made` attribute associated with the `variable-name` token, so we have to make some simple work to access the storage:

```raku-static
method value($/) {
    if $<number> {
        $/.make($<number>.made);
    }
    elsif $<variable-name> {
        $/.make(%var{$<variable-name>});
    }
    else {
        $/.make($<expression>.made);
    }
}
```

The `value` method consists of three branches, whose task is to find an appropriate data to be passed further. In the case of variables, a hash lookup is done.

Having all that, the translator can now process the following program and compute the length of Earth’s equator (assuming we already assigned the value to `pi` earlier):

```raku-static
my r;
r = 6371; # km

my d;
d = 2 * pi * r;
say d;
```

{% include nav.html %}

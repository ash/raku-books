---
title: List assignments
---

{% include menu.html %}

So far, arrays can be created but you have to assign their elements one by one. Let us allow list assignment and initialisation:

```raku-static
my data[] = 111, 222, 333;

data = 7, 9, 11;
```

A new syntax element, comma, appeared here. It does not clash with any other constructs of the language, so it can be easily embedded into the grammar.

```raku-static
rule array-declaration {
    <variable-name> '[' ']' [ '=' <value>+ %% ',' ]?
}

rule assignment {
    <variable-name> <index>? '=' <value>+ %% ','
}
```

In both cases, the value rule is used, which means you can use both numbers, strings, and arithmetical expressions to be initialising values for the array elements:

```raku-static
my strings[] = "alpha", "beta", "gamma";
say strings[1]; # beta

my arr[] = 11, 3 * 4, 2 * (6 + 0.5);
say arr[0]; # 11
say arr[1]; # 12
say arr[2]; # 13
```

To implement it in actions, let’s make a helper method `init-array` that takes the name of the variable and the list of the values:

```raku-static
method init-array($variable-name, @values) {
    %!var{$variable-name} = $[];
    for @values -> $value {
        %!var{$variable-name}.push($value.made);
    }
}

multi method array-declaration($/ where $<value>) {
    self.init-array($<variable-name>, $<value>);
}

multi method assignment($/ where !$<index>) {
    if %!var{$<variable-name>} ~~ Array {
        self.init-array($<variable-name>, $<value>);
    }
    . . .
}
```

When making a new array, you can use `Array.new` instead of `$[]`.

Unlike, for example, the set of operator functions, the `init-array` routine is made a method as it has to have access to the variable storage `%!var`.

{% include nav.html %}

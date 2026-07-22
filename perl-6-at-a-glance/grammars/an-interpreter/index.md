---
title: An interpreter
---

{% include menu.html %}

So far, the grammar sees the structure of the programme and can tell if it is grammatically correct, but it does not execute any instructions contained in the programme. In this section, we will extend the parser so that it can actually execute the programme.

Our sample language uses variables and integer values. The values are constants and describe themselves. For the variables, we need to create a storage. In the simplest case, all the variables are global, and a single hash is required: `my %var;`.

The first action that we will implement now, is an assignment. It will take the value and save it in the variable storage. In the `assignment` rule in the grammar, an `expression` is expected on the right side of the equals sign. An expression can be either a variable or a number. To simplify the variable name lookup, let’s make the grammar a bit more complicated and split the rules for assignments and printing out into two alternatives.

```raku-static
rule assignment {
    | <identifier> '=' <value>
    | <identifier> '=' <identifier>
}
rule printout {
    | 'print' <value>
    | 'print' <identifier>
}
```

```

```

{% include nav.html %}

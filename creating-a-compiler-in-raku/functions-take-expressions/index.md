---
title: Functions take expressions
---

{% include menu.html %}

Another ad-hoc solution that still presents in the grammar is a function call. It can only take a variable name as its argument. We’ll dedicate a separate chapter to functions but now let us allow the following programs:

```raku
say 42;
say 100 + 300 / 3 ** (7 - 5);
```

Instead of a variable, an expression is passed here. So, update the `function-call` rule:

```raku-static
rule function-call {
    <function-name> <expression>
}
```

The action also needs an update. And a great thing that switching to expressions, we made the action simple. This is how it looked before:

```raku-static
method function-call($/) {
    say %!var{$<variable-name>} if $<function-name> eq 'say';
}
```

And this is how it looks now:

```raku-static
method function-call($/) {
    say $<expression>.made;
}
```

A function just uses the value computed somewhere else and does not do any variable checks.

In this chapter, we made many transformations of the grammar and its associated code. This made the grammar more transparent and even allowed us to make some nice additions. Consult the repository to make sure we are on the same page.

{% include nav.html %}

---
title: Dynamic variables
---

{% include menu.html %}

The scope of dynamic variables is calculated at the moment when a variable is accessed. Thus, two or more calls of the same code may produce different results.

Dynamic variables are marked with the `*` twigil (a character clearly referencing a wildcard).

In the following example, the `echo()` function prints a dynamic variable `$*var`, which is not declared in the function, nor is it a global variable. It, nevertheless, can be resolved when used in other functions, even if they have their own instances of the variable with the same name.

```raku
sub alpha {
    my $*var = 'Alpha';
    echo();
}

sub beta {
    my $*var = 'Beta';
    echo();
}

sub echo() {
    say $*var;
}

alpha(); # Alpha
beta();  # Beta
```

{% include nav.html %}

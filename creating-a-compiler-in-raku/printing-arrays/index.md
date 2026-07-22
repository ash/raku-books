---
title: Printing arrays
---

{% include menu.html %}

Another thing, which is really desired for arrays, is to allow print them at once. Instead of listing separate elements, we’d like to pass the whole array to the `say` function:

```raku-static
my data[] = 5, 7, 9;
say data;
```

In fact, Raku can already do that, because our implementation of `say` just passes the whole container to Raku’s `say`, which prints the data like this:

```
[5 7 9]
```

Let us be less humble and create our own output format by checking the type of the variable, as we did before:

```raku-static
method function-call($/) {
    my $object = $<value>.made;

    if $object ~~ Array {
        say $object.join(', ');
    }
    else {
        say $object;
    }
}
```

This function prints the array as a comma-separated list of its items:

```
5, 7, 9
```

{% include nav.html %}

---
title: 68. Sort hashes by parameter
---

{% include menu.html %}

*Sort a list of hashes using data in their values.*

This task is commonly performed to sort items where the sortable parameter is one of the values in the hash, for example, sorting a list of people by age.

```raku-static
my @people = (
    {
        name => 'Kevin', age => 20,
    },
    . . .
    {
        name => 'Amanda', age => 19,
    },
);

@people.sort( *<age> ).say;
```

Using `*<age>` is the same as `{%^a<age> <=> %^b<age>}`.

The `sort` method uses an optional code block that customises the sorting procedure. It takes two arguments, compares them, and returns the result of the comparison.

In the example shown, `%^a` and `%^b` are the two placeholder variables created by the compiler. They alphabetically correspond to the first and the second arguments that the block receives.

Alternatively, it is possible to list the arguments in a pointy block explicitly:

```raku-static
@people.sort( -> %first, %second {
    %first<age> <=> %second<age>
}).say;
```

{% include nav.html %}

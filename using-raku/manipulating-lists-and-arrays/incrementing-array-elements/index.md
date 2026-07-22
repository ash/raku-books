---
title: 52. Incrementing array elements
---

{% include menu.html %}

*Increment each element in an array.*

In Raku, there is no need to explicitly iterate over an array to apply some operation to each element. Use a hyper-operator:

```raku-static
@data>>++;
```

Let us try it on a small array:

```raku
my @data = 1..10;
@data>>++;
say @data; # [2 3 4 5 6 7 8 9 10 11]
```

The `>>++` operator is a hyper-operator that applies the `++` operator to each element of the array. As the `++` operator modifies the element, the whole `@data` array is also modified after the operation.

Alternatively, one of the following forms may be used:

```raku-static
@data <<+=>> 1;
@data >>+=>> 1;
```

These constructions take every element of the array and perform the `+= 1` operation on it.

Notice that if you omit the `=` sign in the last examples, the original data is not modified.

```raku
my @data = 1..10;
my @new-data = @data >>+>> 1;
say @data;     # [1 2 3 4 5 6 7 8 9 10]
say @new-data; # [2 3 4 5 6 7 8 9 10 11]
```

{% include nav.html %}

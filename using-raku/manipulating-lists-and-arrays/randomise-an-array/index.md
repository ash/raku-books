---
title: 51. Randomise an array
---

{% include menu.html %}

*Shuffle the elements of an array in random order.*

Arrays in Raku have the `pick` method, which does the work.

```raku
my @a = 1..20;
say @a.pick(@a);
```

A possible output of the program looks like this:

```
(4 18 10 15 14 8 2 11 3 12 1 6 9 19 13 7 16 17 20 5)
```

The `pick` method expects an integer argument that defines the number of picked elements. In the example above, passing the array as an argument causes the language to coerce it into an integer by calling the `@a.Int` method, which returns the length of the array.

After the operation, the original data remains unchanged. If you need to update the `@a` variable, use the `.=` operator to call a method and assign its result to the invocant:

```raku-static
@a.=pick(@a);
```

Elements of the array are not repeated in the output.

Arrays also have the `roll` method, which works similar but does not guarantee that the elements are not repeated.

```raku-static
say @a.roll(@a);
```

Calling either `pick` or `roll` with no argument returns a single element from an array. If the value of the argument is bigger than the length of the array, the `pick` method returns the list of the same size as the original one, while `roll` happily generates more repeated items.

{% include nav.html %}

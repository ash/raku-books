---
title: 45. Compose the largest number
---

{% include menu.html %}

*Given the list of integers, compose the largest possible number by concatenating them.*

This task requires working with the same data as with numbers and strings. To compose the largest possible number out of a list of integers, we need to reorder them so that the largest numbers come first.

The easiest way to achieve that is to treat numbers as strings, sort them alphabetically in descending order, concatenate the pieces to a single string, and get the resulting integer.

```raku
my @a = (67, 8, 1, 5, 45);

say @a.sort({$^b.Str cmp $^a.Str}).join;
```

Sorting an array is achieved by the `sort` method, which optionally takes the code block that is used in comparison:

```raku-static
{$^b.Str cmp $^a.Str}
```

The two special variables, `$^a` and `$^b`, are the so-called placeholders that get the values of the arguments passed to the code block. The order of the arguments corresponds to the alphabetical order of the variables. It can be either `$^a` and `$^b` or `$^x` and `$^y` or even `$^arg1` and `$^arg2`. As the goal is to sort strings in descending order, `$b` is mentioned first in comparison.

During the sorting procedure, `$^a` and `$^b` are referencing to different elements of the given array. The `cmp` operator is the universal comparison operator. To make sure the arguments are sorted alphabetically, they are both casted to strings by calling the `Str` method.

The result of running the program is `8675451`.

{% include nav.html %}

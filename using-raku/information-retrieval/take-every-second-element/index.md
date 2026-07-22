---
title: 60. Take every second element
---

{% include menu.html %}

*Form a new array by picking every second element from the original array.*

There is an array of numbers, and the task is to pick every second element and put them into a new array.

Prepare the test data:

```raku-static
my @data = 20..30;
```

Here is a possible solution:

```raku-static
my @selected = @data[1, 3 ... *];
say @selected;
```

This program prints the following values:

```
[21 23 25 27 29]
```

We are using a slice to provide the needed indices within the pair of square brackets. To make a slice, just list more than one element inside the brackets, for example:

```raku-static
say @data[2, 3, 5]; # (22 23 25)
```

To select every second element, a sequence `1, 3 ... *` is created. The `...` sequence operator creates a sequence based on the example list provided on its left side. The two numbers, 1 and 3, provide a pattern for the arithmetic progression; thus, every element is calculated as 8/ = 8/01 + 2.

The star at the right end of the sequence ensures that the sequence is generated until the whole array has been looked up. Using the `*` is a very nice way to ask the compiler to do the right job for you (the Do What I Mean, or DWIM, principle).

{% include nav.html %}

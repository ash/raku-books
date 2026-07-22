---
title: 71. Pascal triangle
---

{% include menu.html %}

*Generate the numbers of the Pascal triangle and print them.*

The Pascal triangle is a sequence of rows of integers. It starts with a single 1 on the top row, and each following row has one number more, starting and ending with 1, while all of the other items are the sums of the two elements above it in the previous row. It is quite obvious from the illustration:

```
1 1
1 2 1
1 3 3 1
1 4 6 4 1
1 5 10 10 5 1
1 6 15 20 25 6 1
```

To calculate the values of the next row, you may want to iterate over the values of the current row and make the sums with the numbers next to it. Let us use the functional style that the language offers.

Consider the fourth row, for example: `1 3 3 1`. To make the fifth row, you can shift all the values by one position to the right and add them up to the current row:

```
1 3 3 1
+   1 3 3 1
  1 4 6 4 1
```

In terms of arrays and assuming that the values of the fourth row are now contained in the `@row` variable, the calculations above are equivalent to the sum of the two arrays: current values in `@row` and a list of values that include `0` and all the values of `@row`. A trailing zero can be added to the current `@row` to make the arrays equally long.

This approach is illustrated by the following diagram:

```
  1 3 3 1 0
+ 0 1 3 3 1
  1 4 6 4 1
```

Now, write that down in the Raku syntax using the technique from Task 53,

*Adding up two arrays.*

```raku-static
@row = (|@row, 0) >>+<< (0, |@row);
```

Notice that the arrays are flattened with the help of a vertical bar: `|@a`. Without that, the `(@row, 0)` list is a list of two elements—an array and a scalar. Compare the output of the following test constructions:

```raku
my @row = 1, 2, 3;
say (@row, 0);  # ([1 2 3] 0)
say (|@row, 0); # (1 2 3 0)
```

Now, complete the program: we need to initialize the `@row` and add some printing instructions and create a loop:

```raku
my @row = 1;
say 1;
for 1..6 {
    @row = (|@row, 0) >>+<< (0, |@row);
    say @row.join(' ');
}
```

The program prints the first seven rows of the Pascal triangle. The rows are not centred and are aligned to the left side.

As an extra exercise, modify the program so that it prints the triangle as it is shown at the beginning of this task. For example, you can first generate rows and keep them in a separate array and then, knowing the length of the longest string, add some spaces in front of the rows before printing them.

{% include nav.html %}

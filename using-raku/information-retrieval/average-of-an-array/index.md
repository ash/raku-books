---
title: 56. Average of an array
---

{% include menu.html %}

*Find the average value of the given array of numbers.*

Calculating the average value of an array has two subtasks—calculate the sum and divide it by the size of the array. So, one of the solutions can look like this:

```raku
my @data = 7, 11, 34, 50, 200;
say sum(@data) / @data;
```

Here, the `sum` built-in function returns the sum of the elements of the `@data` array. To get the size of an array, you may call the `elems` method:

```raku-static
say sum(@data) / @data.elems;
```

This is a straightforward way, which is a bit redundant for our task. As the `@data` is used in numeric context as an operand of the division operator, explicitly calling the `elems` method is not necessary.

Another approach is to use the reduction operator:

```raku-static
say ([+] @data) / @data;
```

In this example, `[+] @data` is equivalent to `@data[0] + @data[1] + ... +` `@data[N]`, where the `+` operator is placed between all the elements of the array.

Be careful with the parentheses in this code. If you omit them, the result will be incorrect, as the actual sum consists of a single element `@data /` `@data`, which equals one. If you omit the space before the opening brace, it will be considered as a parenthesis grouping the arguments of the `say` function, and the result is also incorrect, as the code prints only the sum of the array elements and divides the result of `say` (which is `1`).

{% include nav.html %}

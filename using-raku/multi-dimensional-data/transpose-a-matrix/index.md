---
title: 67. Transpose a matrix
---

{% include menu.html %}

*Take a matrix and print its transposed version.*

A matrix can be represented by nested arrays or lists. For example, here’s a square 2×2 matrix:

```raku-static
my @matrix = [1, 2],
             [3, 4];
```

This is how the transposed matrix should look:

```
[[1, 3],
[2, 4]]
```

Actually, the outer pair of square brackets, could be added to the initializer of the `@matrix` variable. Raku simply converts the list `([1, 2], [3, 4])` to an array when assigning it to an array variable `@matrix`.

Transposing a matrix is extremely easy:

```raku-static
my @transposed = [Z] @matrix;
```

The `[Z]` operator is a reduction form of the zip operator. For the given small matrix, it’s action is equivalent to the following code:

```raku-static
my @transposed = [1, 2] Z [3, 4];
```

Despite the simplicity of the method, it works well with bigger matrices as well as non-square ones.

For the example `@matrix` in this task, the output of the program is the following:

```
[(1 3) (2 4)]
```

{% include nav.html %}

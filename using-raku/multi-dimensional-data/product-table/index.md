---
title: 70. Product table
---

{% include menu.html %}

*Generate and print the product table for the values from 1 to 10.*

The task does not say anything about how to format the output.

First, let us print the results as a list with one line per one multiplication. In Raku, there is a cross operator `X`, which operates over lists and creates a cross product of them. Each element of the result list is a list of two elements coming from each of the operands of the `X` operator.

```raku
say "$_[0]×$_[1] = {[*] @$_}" for 1..10 X 1..10;
```

In each iteration, the loop variable `$_` receives a list of two elements. They are printed inside the interpolated list: `$_[0]×$_[1]`. The string in double quotes also contains a block of code in curly braces, which is executed as a regular code.

The reduction operation is used here to multiply the two elements. Of course, it is possible to do multiplication directly: `$_[0]*$_[1]`.

The output looks like this:

```
1×1 = 1
1×2 = 2
1×3 = 3
. . .
10×8 = 80
10×9 = 90
10×10 = 100
```

Now, let us print the result in the form of a table and try minimizing the code starting with two loops:

```raku
for 1..10 -> $x {
    for 1..10 -> $y {
        print $x * $y ~ "\t";
    }
    print "\n";
}
```

As the loop body of the inner cycle contains only one statement, it is possible to rewrite it by using the postfix `for` loop:

```raku
for 1..10 -> $x {
    print "{$x * $_}\t" for 1..10;
    print "\n";
}
```

Finally, join the output using the `join` function, which also helps to eliminate trailing tabulation characters at the end of lines:

```raku
for 1..10 -> $x {
    say join("\t", map {$x * $_}, 1..10);
}
```

It is also possible to call the functions as methods on lists:

```raku
for 1..10 -> $x {
    (1..10).map({$x * $_}).join("\t").say;
}
```

Further optimization isn’t easy because two variables are needed for multiplication, while only one `$_` can be used as a default loop variable. Now the result is a proper table:

```
1  2  3  4  5  6  7  8  9  10
2  4  6  8  10 12 14 16 18 20
3  6  9  12 15 18 21 24 27 30
. . .
```

{% include nav.html %}

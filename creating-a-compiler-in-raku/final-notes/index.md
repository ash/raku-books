---
title: Final notes
---

{% include menu.html %}

In this chapter, we managed to convert strings to numbers, but what kind of numbers are they? To get the numbers, we were using operators that are available in Raku, such as binary `+`, arithmetic operators, and the power operator `**`. The result of the calculations that use all of those is a number that is an instance of one of the numeric types that Raku offers.

You can see the class name by explicitly printing it in the test loop:

```raku-static
say "OK $number = " ~ $test.made ~
    ' (' ~ $test.made.^name ~ ')';
```

All numbers that did not contain a decimal point became `Int`s, all the rest are `Rat`s:

```
OK 7 = 7 (Int)
OK 77 = 77 (Int)
OK -84 = -84 (Int)
OK +7 = 7 (Int)
OK 0 = 0 (Int)
OK 3.14 = 3.14 (Rat)
OK -2.78 = -2.78 (Rat)
OK 5.0 = 5 (Rat)
OK .5 = 0.5 (Rat)
OK -5.3 = -5.3 (Rat)
OK -.3 = -0.3 (Rat)
OK 3E4 = 30000 (Int)
OK -33E55 = -330000000000000000000000000000000000000000000000000000000 (Int)
OK 3E-3 = 0.003 (Rat)
OK -1E-2 = -0.01 (Rat)
OK 3.14E2 = 314 (Rat)
OK .5E-3 = 0.0005 (Rat)
```

Now, look again at the `floating-point` method in the actions class. Although its algorithm is straightforward and produces correct results, it is quite wordy and needs a few lines of code. Alternatively, you can pass this task to the host language itself! Let Raku parse the floating-point number for you:

```raku-static
my $n = +"$int.$frac";
$/.make($n);
```

Wait, what is `"$int.$frac"`? It is a string that was matched by the `floating-point` token during the parsing process, and it means that instead of reconstructing the string and converting it to a number, we can access it directly converting the `$/` object to a number directly:

```raku-static
method floating-point($/) {
    $/.make(+$/);
}
```

Does this code resemble something that you’ve already seen? The body of this method is exactly the same as the body of the `integer` method:

```raku-static
method integer($/) {
    $/.make(+$/);
}
```

Indeed, we allowed Raku to build the number for us when it contained digits only. We can delegate it again if we met a number with a decimal point, too.

But that’s not all. The numbers that our `Number` grammar allows are all valid Raku numbers, and it is possible to replace all our actions with a single line of code:

```raku-static
class NumberActions {
    method TOP($/) {
        $/.make(+$/);
    }
}
```

After this change, the types of the number differ a bit. Raku treats a number in the scientific notation as `Num`, not `Rat`. You can confirm that by running the test loop again:

```
OK 7 = 7 (Int)
OK 77 = 77 (Int)
OK -84 = -84 (Int)
OK +7 = 7 (Int)
OK 0 = 0 (Int)
OK 3.14 = 3.14 (Rat)
OK -2.78 = -2.78 (Rat)
OK 5.0 = 5 (Rat)
OK .5 = 0.5 (Rat)
OK -5.3 = -5.3 (Rat)
OK -.3 = -0.3 (Rat)
OK 3E4 = 30000 (Num)
OK -33E55 = -3.3e+56 (Num)
OK 3E-3 = 0.003 (Num)
OK -1E-2 = -0.01 (Num)
OK 3.14E2 = 314 (Num)
OK .5E-3 = 0.0005 (Num)
```

The output format here also depends on how Raku prints the numbers of different numerical types.

In this particular task, all our manual labour is replaced by the compiler actions in the host language. Of course, that was possible because we chose standard data formats that many programming languages can deal with. Do not be afraid to remove your own code as soon as you discovered a simpler way to solve the task.

The techniques of working with AST that were demonstrated in this chapter, are the base for our future adventure in this book. Stay tuned!

{% include nav.html %}

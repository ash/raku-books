---
title: 34. Histogram of random numbers
---

{% include menu.html %}

*Test the quality of the random generator by using a histogram to visualise the distribution.*

The quality of the built-in generator of random numbers fully depends on the algorithm the developers of the compiler used. As a user, you cannot do much to change the existing generator, but you can always test if it delivers numbers uniformly distributed across the whole interval.

There is the `rand` routine (see Task 32, Generating random numbers) that returns a floating-point number (actually, the value of the `Num` type) between 0 and 1. We will run it 100,000 times, filling the histogram containing 10 cells. Each random number falls into one of them. For example, the numbers between 0 and 0.1 land in the first cell, the numbers between 0.1 and 0.2 in the second, and so on.

```raku
my @histogram;
@histogram[10 * rand]++ for 1..100_000;
say @histogram;
```

Examine the way the index for the `@histogram` array is formed. A random integer between 0 and 1 is first multiplied by 10 and then an integer part of it is taken because the array indexing operator `[ ]` needs integers only. It is also possible to do the conversion explicitly:

```raku-static
@histogram[(10 * rand).Int]++
```

Run the program a few times. Here’s the output of a couple of runs of the program, and it printed more or less equal numbers in each cell:

```
[10062 9818 10057 9922 10002 10118 9978 9959 10013 10071]
[9959 9957 9813 9933 10160 10030 10036 10032 10059 10021]
```

{% include nav.html %}

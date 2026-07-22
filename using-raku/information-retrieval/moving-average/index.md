---
title: 57. Moving average
---

{% include menu.html %}

*Calculate the moving average for the given array of numbers.*

For each element of an array, the moving average is the average value of the last few items or the few elements around it. This kind of analysis is often used to smooth the curve.

Let us first generate some random data—an array of a hundred values between 0 and 1:

```raku-static
my @data = map {rand}, 1..100;
```

Now, calculate the average values for (almost) each point using three items before and three items after the current item:

```raku-static
my @average = map {
    sum(@data[$_ - 3 .. $_ + 3]) / 7
}, 3..96;
```

The beginning and the end of an initial array do not have enough neighbouring elements; that’s why they are skipped.

Inside the `map` function, the code block calculates the sum of an array slice:

```raku-static
sum(@data[$_ - 3 .. $_ + 3]).
```

Here is a graph with the results of a test run of this program. The inner curve corresponds to the values of the `@average` array.

{% include nav.html %}

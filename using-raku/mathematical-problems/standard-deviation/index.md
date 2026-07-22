---
title: 36. Standard deviation
---

{% include menu.html %}

*For the given data, calculate the standard deviation value (sigma).*

Standard deviation is a statistical term that shows how compact data distribution is. The formula is the following:

5 = 6∑(89 −8̅)3 , ; −1

where N is the number of elements in the array x; 8̅ is the average value (see

*Task 56, Average on an array).*

Let’s use some test data from Wikipedia and take the straightforward approach using reduction operations and avoiding explicit loops:

```raku-nobrowser
my @data = 727.7, 1086.5, 1091.0, 1361.3, 1490.5, 1956.1;

my $avg = ([+] @data) / @data.elems;
my $sigma = sqrt(
    ([+] map * ** 2, map * - $avg, @data) /
    (@data.elems - 1)
);

say $sigma; # 420.962489619523
```

Inside the `sqrt` function, the `[+]` reduction operator gets the array that is formed by the two nested runs of `map`. First, the constant shift has been removed by applying `* - $avg` to each element. Second, a square of each item has been calculated: `* ** 2`.

In both cases, the `WhateverCode` is used. It is usually more expressive but may lead to constructs like `* ** 2`, which look a bit cryptic.

The two `map`s can be merged into one:

```raku-static
my $sigma = sqrt(
    ([+] map (* - $avg) ** 2, @data)  / (@data.elems - 1)
);
```

Now, let’s explore the second approach that gets the same result using feed operators. In Raku, there are feed operators of both directions: `<==` and `==>`. Their shape indicates the direction of data flow, so here is another version of the program.

```raku-nobrowser
my @data = 727.7, 1086.5, 1091.0, 1361.3, 1490.5, 1956.1;

my $avg = ([+] @data) / @data.elems;
@data
    ==> map * - $avg
    ==> map * ** 2
    ==> reduce * + *
    ==> my @σ;
say sqrt(@σ[0] / (@data.elems - 1)); # 420.962489619523
```

The data flow is clearly visible now. The `@data` array passes the two maps, and then, it is reduced using the `+` operation. The call of `reduce * + *` is equivalent to using the reduction operator in the form of `[+]`.

Notice how the `@σ` array is defined, not only the fact that a Unicode name is used but mostly the fact that the `my` declaration is placed at the end of the feed chain. An array is used here because the feed operator does not return a scalar value, although we only need one element.

To make the code even closer to the original mathematical formula, you may choose a different name for the variable holding the average value (and remove the `elems` call):

```raku-static
my $x̄ = ([+] @data) / @data;
```

{% include nav.html %}

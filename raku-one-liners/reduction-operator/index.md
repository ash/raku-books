---
title: Reduction operator
---

{% include menu.html %}

Our next guest is a reduction construction with a pair of square brackets. When they do not surround an array index, they work in a completely different field.

Example 1: Factorial

The most classical example is using the reduction operator to calculate factorial:

```raku
say [*] 1..2019
```

`[ ]` is a reduction meta-operator. The meta part of the name tells us that it can be used as an envelope for another operator (and not only an operator, by the way).

In the first example, the operator includes another operator, and the whole line can be re-written by enrolling the range to a list and placing the `*` between all its elements:

```raku
say 1 * 2 * 3 #`(more elements) * 2018 * 2019
```

Example 2: Using a function

Now, let us find the smallest number, which is divisible by all numbers from 1 to 20.

Let me show you a direct answer in Raku:

```raku
say [lcm] 1..20
```

This code looks very similar to the previous example, but uses another operator, the `lcm` routine, which is a built-in infix operator. The name stands for least common multiplier, but in the documentation, you can also read that

*it returns the smallest integer that is evenly divisible by both arguments. Al-*

most the same words, which were used to formulate the problem we solve.

```raku
say 1 lcm 2 lcm 3 lcm 4 lcm 5 lcm 6 lcm 7 # ... and up to 20
```

Example 3: Matrices

Other infix operators that are already built-in in Raku, can also be very productive. Here’s an example of rotating a matrix with just a few characters of code:

```
[Z] <A B C>, <D E F>, <H I J>
```

Here, we are transforming a two-dimensional matrix with nine elements, the one-character strings `A` through `J`. In the output, the rows become columns, and columns become rows:

```
((A D H) (B E I) (C F J))
```

The zip infix operator `Z` has been inserted between the elements of the list, and thus the code is similar to the following:

```
<A B C> Z <D E F> Z <H I J>
```

Notice, that if you want to emphasise the order of operations, you might not get exactly what you wanted:

```
> (<A B C> Z <D E F>) Z <H I J>
(((A D) H) ((B E) I) ((C F) J))
```

OK, before we have too much Lisp, let’s change the topic.

{% include nav.html %}

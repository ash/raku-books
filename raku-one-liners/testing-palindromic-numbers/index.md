---
title: Testing palindromic numbers
---

{% include menu.html %}

The task is to find the largest palindromic number (the number that reads from both ends, such as 1551), which is a product of two three-digit numbers.

In other words, we have to scan the numbers below 999×999, and could optimise the solution, but in reality, we only have to allow numbers, which are products, thus, let’s not skip the multiplication part.

Here’s our one-liner:

```raku
(((999...100) X* (999...100)).grep: {$^a eq $^a.flip}).max.say
```

You are already prepared to the fact that chained method calls are very handy for using in Raku one-liners.

We also saw the colon-form of method calls earlier, but this time we are using a code block with a placeholder variable. It is not quite clear if you can use a star here, as we need the variable twice in the block.

The first part of the line uses the cross-operator `X*`, (see Chapter 6). It generates products of all three-digit numbers. As we need the largest number, it makes sense to start from right to left, that’s why the sequence `999...100`, but not `100...999`.

Let’s look at the first few numbers in the grepped sequence of products:

```
580085 514415 906609 119911 282282 141141 853358 650056
```

One-liners are not always very optimal. In our case, we need to generate the whole sequence of products to find the maximum among them. The answer resides at the third position, so it will be a mistake to replace `max` with `first`. But the good part is that if you use `first`, Raku will not generate all the numbers. There’s another useful method, `head`, which also prevents generating more than necessary.

The following code runs much faster and gives the correct result:

```raku
(((999...100) X* (999...100)).grep:
    {$^a eq $^a.flip}).head(10).max.say
```

{% include nav.html %}

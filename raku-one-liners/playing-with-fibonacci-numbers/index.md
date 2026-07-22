---
title: Playing with Fibonacci numbers
---

{% include menu.html %}

Yes, most likely, you never used such numbers in real code, and, again, most likely, you solved many educating problems with them. Nevertheless, today, let’s try to approach the shortest solution for a Fibonacci problem on the Code-Golf.io site (see also Chapter 7 about Golf coding).

How do we form a Fibonacci sequence? With a sequential operator `...`:

```
0, 1, * + * ... *
```

If you want some exotic flavour in the code, you can replace the last star with either `Inf` or ∞. In any case, the result is a lazy sequence of the `Seq` type. Raku does not compute it immediately (and it can’t, as the right edge is infinite).

Finally, let’s find the index of the first Fibonacci number, which has 1000 digits. Of course, you can loop over the above-created sequence and trace the index yourself. But in Raku, there is an option to modify the `grep` routine family and ask it to return the index of the matched item instead of the item itself.

Also, instead of `grep`, we’ll use a more appropriate method, `first`. It returns the first matching item or its index if we call the method with the `k` key. It is enough just to mention the key; no value is really needed.

```raku
say (0, 1, * + * ... *).first(*.chars >= 1000, :k)
```

This program prints a single integer number, which is the correct answer to the given problem.

{% include nav.html %}

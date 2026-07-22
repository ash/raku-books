---
title: Adding up even Fibonacci numbers
---

{% include menu.html %}

The task here is to find the sum of all even Fibonacci numbers below four million.

Here’s the complete solution:

```raku
(1, 1, * + * ...^ * >= 4_000_000).grep(* %% 2).sum.say
```

It is equally interesting to parse the code from either left or right end. Let’s start from left.

Inside the first parentheses, we are generating a sequence of Fibonacci numbers which starts with two 1s, and each next generated number is a sum of the two previous ones. You can express it using a `WhateverCode` block: `* +` `*` is equivalent to `{$^a + $^b}`.

A less known feature of sequences is the final condition. In many examples you would see either a bare star or an `Inf`. In our example, we limit the sequence with an explicit upper boundary.

Notice that you cannot simply write:

```
1, 1, * + * ... 4_000_000
```

To visualise it better, try a smaller limit, say 100:

```
> (1, 1, * + * ... 100)
(1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584
```

The generation does not stop when the sequence crosses our desired border. It only stops if the next calculated element of the sequence equals to the given number exactly, for example:

```
> (1, 1, * + * ... 144)
(1 1 2 3 5 8 13 21 34 55 89 144)
```

If you don’t know the Fibonacci number preceding four million, use another `WhateverCode` block with a Boolean condition: `* >= 4_000_000`. Notice that the condition is opposite to what you would write in a regular loop, and we are demanding more than four million, not less than. This is the condition that becomes `True` when you have to stop the sequence. Instead of the star, you could use the default variable: `{$_ >= 4_000_000}`.

The rest of the code greps even numbers and adds them up.

{% include nav.html %}

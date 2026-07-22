---
title: Playing with prime numbers
---

{% include menu.html %}

Let us solve the problem where you need to print the 10001st prime number (having the first being 2).

The Raku programming language is good at prime numbers, as it has a builtin method `is-prime`, defined for `Int`s.

There are a few ways of generating prime numbers. For one-liners, the best is the simplest (but the least efficient) method that tests every number.

```raku
say ((1..*).grep: *.is-prime)[10000]
```

It takes about half-a-minute to compute the result, but the code is quite short. Solving the task using the so-called sieve of Eratosthenes is much more efficient, but it probably requires more lines of code, thus it is not a oneliner and is out of scope of this book.

{% include nav.html %}

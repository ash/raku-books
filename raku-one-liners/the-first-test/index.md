---
title: The first test
---

{% include menu.html %}

Let us play Golf and print all prime numbers below 100.

My solution, which needs 22 characters, is the following:

```raku-static
.is-prime&&.say for ^
```

There is no shorter solution in Raku, while in the J programming language, they managed to have only 11 characters. In Raku, eight characters are consumed by the method name already. I believe, to win all Golf contests, you need a special language with very short names (which J is) and a set of builtin routines to generate lists of prime, or Fibonacci, or any other numeric sequence. It should also strongly utilise the Unicode character space.

In our Raku example, there is also a Unicode character, . This not a simple C, the third letter of the Latin alphabet, but a Unicode character ROMAN NUMERAL ONE HUNDRED (which was originally the third letter of the Latin alphabet, of course). Using this symbol let us saving two characters in the solution.

The `&&` trick is possible because the second part of the Boolean expression is not executed if the first operand is `False`. Notice that you cannot use a single `&` here. The full non-optimised version of the code would require additional spaces and would look like this:

```raku
.say if .is-prime for ^100
```

{% include nav.html %}

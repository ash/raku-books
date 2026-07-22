---
title: Sum of the numbers equal to the sum of factorials of digits
---

{% include menu.html %}

So, the task is to find the sum of all numbers, which are equal to the sum of factorials of their digits. Sounds clear? You may take a look at the solution one-liner to understand it better.

```raku
say [+] (3..50_000).grep({$_ == [+] .comb.map({[*] 2..$_})})
```

Let us start from … something.

We are looping over the range `3 .. 50_000`. The upper boundary is a guess based on some considerations. Let me skip it here, but you may try to find the answer if you are curious. Basically, at some point you understand that the number either contains too many digits or is too big itself.

The second step is to `grep`. We are searching for the numbers which are equal `($_ ==)` to the sum. The sum is computed by the second reduction plus `[+]`, but you may use the `sum` method instead:

```raku-static
{$_ == .comb.map({[*] 2..$_}).sum}
```

Notice that `.comb` is a method called on the default variable `$_`. The `comb` method splits the number into separate digits treating them as characters. The `map` method converts each digit to a factorial (again, using the reduction operator `[*]`).

Finally, the most outer `[+]` adds up all the grepped numbers and passes the result to the `say` routine.

Although the book is about one-liners, in practice you’d better write a twoliner to prepare the factorials before using them:

```raku
my @f = (0..9).map({[*] 1..$_});
say [+] (3..50_000).grep({$_ == [+] .comb.map({@f[$_]})});
```

{% include nav.html %}

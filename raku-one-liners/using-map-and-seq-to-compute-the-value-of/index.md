---
title: Using map and Seq to compute the value of π
---

{% include menu.html %}

In this section, we are computing the value of π using two different methods. The goal is to try different approaches to generate numeric sequences.

Preparation

Of course, you don’t need to calculate the value of π yourself, as the Raku language gives us a few predefined constants in the shape of both `π` and `pi`, as well as doubled values `τ` and `tau`.

But to demonstrate the usage of maps and sequences, let’s implement one of the simplest algorithms to calculate π:

Here’s a draft code to check the answer:

```raku
my $pi = 1;
my $sign = 1;

for 1..10000 -> $k {
    $sign *= -1;
    $pi += $sign / ($k * 2 + 1);
}

say 4 * $pi;
```

Part 1

Now, let us employ `map` to make the solution compact. It is better to make the formula more generic, too:

And here’s our first one-liner:

```raku
say 4 * [+] (^1000).map({(-1) ** $_ / (2 * $_ + 1)})
```

I hope you understand everything here. We covered different parts of this solution in the previous sections of the book.

But still, I want to emphasise that you need parentheses around `-1`. If you type `-1 ** $_`, then you always get −1, as the minus prefix is applied to the result of taking power. So, the correct code is `(-1) ** $_`.

Part 2

It is also interesting to try using a sequence operator `...` to generate the row according to the formula mentioned above. Also, we’ll use rational numbers to create the fractions ⅓, ⅕, etc.

```raku
say 4 * [+] <1/1>,
    {-Rat.new($^n.numerator, $^n.denominator + 2)} ...
    *.abs < 1E-5;
```

This sequence starts with a rational number `<1/1>`, which is handy as we can immediately take its numerator and denominator. The generator block of the sequence uses this number to create a new rational number, whose denominator increases by two on each iteration.

You may ask why I am referring `$^n.numerator`, which is always 1. This is because to alter the sign, we need to know the sign of the current value, and the sign is kept in the numerator part of the rational value.

The placeholder variable `$^n` automatically takes the first (and the only) argument of the generator code block.

The sequence is generated until the absolute value of the current number becomes small enough. It may be tempting to replace the final condition with `*` ≅ `0`, but that program would run too long to produce the result, as the default tolerance of the approximately-equal operator is 10−15, while the row does not converge that fast.

Also, you cannot use the `< ... / ...>` syntax to create a `Rat` number in the generator:

```raku-static
{ <$^n.numerator / $^n.denominator + 2> }
```

In this case, Raku treats this as a quoting construction such as `<red green` `blue>`, and instead of the code block you get a list of strings.

Part 3

Damian Conway suggested the following interesting and compact solution with two sequences:

```raku
say 4 * [+] (1, -1, 1 … *   )
        «/« (1,  3, 5 … 9999);
```

{% include nav.html %}

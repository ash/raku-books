---
title: 33. Neumann’s random generator
---

{% include menu.html %}

*Implement the von Neumann’s random number generator (also known as Middle-square method).*

This algorithm is a simple method of generating short sequences of four-digit random integers. The method has its drawbacks, but for us, it is an interesting algorithmic task. The recipe has these steps:

*1. Take a number between 0 and 9999. 2. Calculate the square of it. 3. If necessary, add leading zeros to make the number 8-digit. 4. Take the middle four digits. 5. Repeat from step 2.*

To illustrate it with an example, let’s take the number 1234 as the seed. On step 2, it becomes 1522756; after step 3, 01522756. Finally, step 4 extracts the number 5227. Now we can implement it in code.

```raku-static
my $n = 1234;
$n **= 2;
$n = sprintf '%08i', $seed;
$n ~~ s/^..(.*)..$/$0/;
say $n;
```

Calculating the square of a number is done using the `**=` operator. This is a meta-operator based on the `**` operator. The value is powered by two, and the result is assigned back to the variable.

It is possible to simplify the steps of taking the middle digits as there is actually no need of adding leading zeroes and asking the regex to always match eight characters. So, instead of capturing the number with `/^..(.*)..$/`, just take zero to four digits before the last two. If there are less than four digits, this is also fine because, in the original algorithm, the missing digits would be zeroes.

```raku
my $n = 1234;
$n **= 2;
$n ~~ /(. ** 0..4)..$/;
say ~$0;
```

We can also get rid of the regex replacement `s///` and use the stringified value of the match object: `~$0`.

Alternatively, instead of treating the number as a string, pure numeric manipulations may be done to achieve the same goal. Getting the middle four digits is possible using integer division and the modulo operation:

```raku-static
my $n = 1234;
$n **= 2;
$n = ($n / 100).Int % 10000;
say ~$0;
```

Whatever method you use, play around with the seed value and see how long the generator has been producing good-looking data.

```raku
my $n = 1234;
for 1..30 {
    $n **= 2;
    $n ~~ /(. ** 0..4)..$/;
    $n = ~$0;
    say $n;
}
```

Notice that in the loop, you need to update `$n` to use it in the next cycle.

In many cases, after some number of repetitions, the values converge to 0000. In some cases, such as with the initial number 2916, the period of the pseudorandom sequence is extremely short.

{% include nav.html %}

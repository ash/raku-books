---
title: 29. Prime factors
---

{% include menu.html %}

*Find the prime factors of a given number.*

Prime factors are the prime numbers that divide the given integer number exactly.

In Task 28, List of prime numbers, we’ve seen how to make a lazily evaluated list of prime numbers. This list is used in the program as a generator of the factor numbers for the tests.

```raku
my $n = 123456789;

my @list;
my @prime = grep {.is-prime}, 1..*;
my $pos = 0;

while $n > 1 {
    my $factor = @prime[$pos];
    $pos++;
    next unless $n %% $factor;

    $pos = 0;
    $n /= $factor;
    push @list, $factor;
}

say @list; # [3 3 3607 3803]
```

On each iteration, the number is tested with the `$n %% $factor` condition. If the factor has been found, it is added to the `@list` array, the current position in the `@prime` arrays is set back to 0 (because factors may repeat), and the number `$n` is divided by the `$factor` value before the next iteration. The loop finishes when the value of `$n` becomes equal to 1.

{% include nav.html %}

---
title: 90. Leap years
---

{% include menu.html %}

*Tell if the given year is leap or common.*

The algorithm for detecting whether the year is leap includes a few divisibility tests. Take an extract in the pseudocode from Wikipedia:

*if (year is not divisible by 4) then (it is a common year) else if (year is not divisible by 100) then (it is a leap year) else if (year is not divisible by 400) then (it is a common year) else (it is a leap year)*

It is possible to implement the above sequence of `if`s and `else`s in Raku, but it is a better idea to join conditions using the logical operators.

```raku
my $year = 2018;
say ($year %% 400 or $year % 100 and $year %% 4) ??
    'Leap' !! 'Common';
```

Notice that both the modulo `%` and divisibility `%%` operators are used, which allow avoiding Boolean negations in the sub-conditions.

The following program prints the list of leap years in the range 1800–2400:

```raku
for 1800 .. 2400 -> $year {
    say $year if $year %% 400 or $year % 100 and $year %% 4;
}
```

There may be some considerations regarding the efficiency of the sequence of the checks because each year is first tested against 400, while it may be more optimal to check first if the year is divisible by 4. If this becomes an important argument, then the `if`-`else` chain may be more efficient. To achieve an even higher speed, a pre-calculated array of leap years is better.

{% include nav.html %}

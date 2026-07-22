---
title: 43. Sum of digits
---

{% include menu.html %}

*Calculate the sum of digits of a given number.*

The solution of this task is based on the `split` method that you can call on any object that is convertible to strings.

The following code takes an integer number and splits it into separate characters, one per digit. Then the reduction operator adds up all the digits, and the result is printed.

```raku
my $number = 139487854;
say [+] $number.split('');
```

The conversion of an integer to a string happens at the moment the `split` method is called. The resulting array contains a number of one-character elements. When they are passed to the `[+]` operator, which expects numeric data, characters are converted back to numbers so that they can be added up as numbers, not strings.

Compare the presented solution with a straightforward approach, where the given number is treated as a number, and a series of divisions has to be performed to get separate digits:

```raku
my $number = 139487854;
my $sum = 0;

while ($number) {
    $sum += $number % 10;
    $number = Int($number / 10);
}
say $sum; # Still prints 49
```

{% include nav.html %}

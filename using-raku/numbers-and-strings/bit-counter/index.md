---
title: 44. Bit counter
---

{% include menu.html %}

*Count the number of bits set to 1 in a binary representation of a positive integer number.*

There are two approaches to this task: either treat the binary sequence as a string or count real bits in the machine representation of the number. Both approaches are fine. We restrict ourselves to the positive integers to avoid dealing with two’s complements representations.

First, use textual approach.

```raku
my $value = prompt('Enter value > ');
$value = $value.Int.base(2);
say "Binary representation: $value";
$value ~~ s:g/0//;
say "Number of 1s: {$value.chars}";
```

The entered value gets converted to a string containing binary representation (see also Task 42, Integer as binary, octal, and hex). Then, all the zeros are removed from the string using the regex substitution:

```raku-static
$value ~~ s:g/0//;
```

At this point, the `$value` string contains only set bits, so the length of the string is the number of such bits. To get the length of the string, call the `chars` method (see Task 3, String length).

Run the program:

```
$ raku bit-count.rk
Enter value > 12345
Binary representation: 11000000111001
Number of 1s: 6
```

Now, the other approach works directly with bits.

```raku
my $value = prompt('Enter value > ');

my $bits = 0;
repeat {
   $bits++ if $value +& 1;
   $value = $value +> 1;
} while $value > 0;

say "Number of 1s: $bits";
```

This program uses two bitwise operators. They are prefixed with `+`: `+&` for the binary AND operation and `+>` for the binary shift.

In the `repeat` … `while` loop, the value is tested for the presence of `1` in the lowest bit: `if $value +& 1`. If this bit is set, the `$bits` counter is incremented.

Then, the `$value` is shifted to the right by one bit (which is equivalent to dividing it by two). The loop is over when the `$value` becomes zero, in other words, when all the bits are shifted out.

Notice that the `$value` variable is seamlessly used first as a string (after returning from the `prompt` routine), and then as an integer.

Test the program with the same input value as in the first example:

```
$ raku bit-count2.rk
Enter value > 12345
Number of 1s: 6
```

If there are no performance demands, the first approach using texts seems to be more natural for Raku; however, if you need higher performance, consider pre-calculating the number of bits and saving it in an array.

{% include nav.html %}

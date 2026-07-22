---
title: 46. Convert to Roman numerals
---

{% include menu.html %}

*Convert an integer number to a Roman numerals string.*

Roman numbers are not a direct translation of the decimal system. In this task, we assume that the number is not more than 3999, which is the maximum a regular Roman number can reach.

Let’s use the algorithm that keeps the table of pre-calculated sequences of Roman letters so that we don’t have to check when III becomes IV, or when another I appears after V, etc.

In the program below, there are four such sequences: for thousands, hundreds, tens, and ones. The program iterates over the digits of the number in the decimal representation and chooses one of the values from the array of lists stored in the `@roman` variable.

```raku
my $n = 2018;

my $roman;
my @roman =
    1000 => < M MM MMM >,
    100  => < C CC CCC CD D DC DCC DCCC CM >,
    10   => < X XX XXX XL L LX LXX LXXX XC >,
    1    => < I II III IV V VI VII VIII IX >;

for @roman -> $x {
    my $digit = ($n / $x.key).Int;
    $roman ~= $x.value[$digit - 1] if $digit;
    $n %= $x.key;
}

say $roman; # MMXVIII
```

Let us examine the structure of the `@roman` container. In the program code, it looks like a hash. Indeed, it could be a hash, but in our case, the algorithm requires division by 1000, 100, and 10, so it is easier to organise data so that they are already sorted in the correct order.

The `< >` quotation construct in the program is the simplest way to create a list from the strings that do not contain spaces. If you print it with the `say` `@roman` instruction, you’ll get the following:

```
[1000 => (M MM MMM) 100 => (C CC CCC CD D DC DCC DCCC CM) 10
=> (X XX XXX XL L LX LXX LXXX XC) 1 => (I II III IV V VI VII
VIII IX)]
```

On the top level, it is a list of pairs, such as `1000 => (M MM MMM)`. Pairs, or objects of the `Pair` class, have the `key` and `value` methods. For the shown example of a pair, the `key` method returns `1000`, and the `value` method returns a list `(M MM MMM)`.

The digits of the input number `$n` are scanned from left to right:

```raku-static
my $digit = ($n / $x.key).Int;
```

The value of `$n` also becomes smaller and smaller at each step:

```raku-static
$n %= $x.key;
```

At each iteration, the next digit lands in the `$digit` variable, and it is used as the index that selects the correct Roman representation:

```raku-static
$roman ~= $x.value[$digit - 1] if $digit;
```

As zeros in the decimal form have no correspondence to the Roman numbers, only non-zero values are taken. When the loop is over, the `$roman` variable contains the desired Roman string.

The opposite conversion is examined in Task 84, Decode Roman numerals.

{% include nav.html %}

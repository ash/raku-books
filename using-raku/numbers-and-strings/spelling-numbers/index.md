---
title: 47. Spelling numbers
---

{% include menu.html %}

*Write an integer number below one million in words.*

Human languages have many inconsistencies, especially in the most frequent constructs. Spelling numbers seems to be a simple task, but due to a number of small differences, the resulting program is quite big.

The program is listed on the next page. Let’s discuss the algorithm first.

Take a number; for example, 987,654. The rules for spelling out the groups of three digits, 987 and 654, are the same. For the first group, the word thousand must be added.

Now, examine a group of three digits. The first digit is the number of hundreds, and it has to be spelled only if it is not zero. If it is not zero, then we spell the digit and add the word hundred.

Now, remove the leftmost digit, and we’ve got two digits left. If the remaining two digits form the number from 1 to 20, then it can be directly converted to the corresponding name. The names for the numbers from 0 to 10 are obviously different. The names for the numbers from 11 to 19 have some commonalities, but is it still easier to directly prepare the names for all of them.

For the larger numbers (21 to 99), there are two cases. If the number is dividable by 10 then a name for 20, 30, 40, etc. is taken. If not, then the name is built of the name of tens and the name for units, joined with a hyphen, such as forty-five.

The zero name appears only in the case when the given number is zero.

In the program, the names are listed in the `@names` array. The `if`—`elsif`— `else` chain implements the above-described procedure.

```raku-static
my @names = <zero one two three four five six seven eight
             nine ten eleven twelve thirteen fourteen fifteen
             sixteen seventeen eighteen nineteen twenty
             thirty forty fifty sixty seventy eighty ninety>;

sub spell-number($number) {
    my $n = $number.Int;

    my $r;
    if $n < 20 {
        $r = @names[$n];
    }
    elsif $n < 100 {
        $r = @names[$n / 10 + 18];
        $r ~= '-' ~ @names[$n % 10] if $n % 10;
    }
    elsif $n < 1000 {
        $r = @names[$n / 100] ~ ' hundred';
        $r ~= ' ' ~ spell-number($n % 100) if $n % 100;
    }
    else {
        $r = spell-number($n / 1000) ~ ' thousand';
        $r ~= ' ' ~ spell-number($n % 1000) if $n % 1000;
    }

    return $r;
}
```

Try running the program with a few different numbers:

```raku-static
say spell-number(987654);  # nine hundred eighty-seven
                           # thousand six hundred fifty-four
say spell-number(0);       # zero
say spell-number(17);      # seventeen
say spell-number(100_001); # one hundred thousand one
```

All work well, but you can do it differently with the help of multi-subs. In the next version of the program, the chain of the checks is replaced with the same number of subroutines that know with what numbers they can work best. The common part is extracted to a separate sub `spell-part`.

```raku-static
my @names = <zero one two three four five six seven eight
             nine ten eleven twelve thirteen fourteen fifteen
             sixteen seventeen eighteen nineteen twenty
             thirty forty fifty sixty seventy eighty ninety>;

multi sub spell-number(Int $n where {$n < 20}) {
    return @names[$n];
}

multi sub spell-number(Int $n where {$n < 100}) {
    my $r = @names[$n / 10 + 18];
    $r ~= '-' ~ @names[$n % 10] if $n % 10;
    return $r;
}

multi sub spell-number(Int $n where {$n < 1000}) {
    return spell-part($n, 100, 'hundred');
}

multi sub spell-number(Int $n where {$n < 1_000_000}) {
    return spell-part($n, 1000, 'thousand');
}

sub spell-part(Int $n, Int $base, Str $name) {
    my $r = spell-number(($n / $base).Int) ~ ' ' ~ $name;
    $r ~= ' ' ~ spell-number($n % $base) if $n % $base;
    return $r;
}
```

Modify the program to process numbers greater than a million.

{% include nav.html %}

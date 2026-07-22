---
title: 41. Binary to integer
---

{% include menu.html %}

*Convert a binary number to a decimal integer.*

Raku is good at its ease of switching between numerical and string representation of the same data. This task is an example where this feature can be used.

The idea is to take a binary number, treat it as a string, prepend the `0b` prefix indicating the binary value, and convert the value back to the integer, but a decimal this time. This description is encoded in the following example:

```raku
my $bin = '101101';
my $int = "0b$bin".Int;
say $int;
```

This program prints `45`.

It is possible to use an alternative representation of the binary number using a generic form of the value with an explicit radix:

```raku
my $bin = '101101';
my $int = ":2<$bin>".Int;
say $int;
```

As a side note, remember that you cannot start a numeric literal with 0. For example, the following assignment is incorrect:

```raku-static
my $b = 0110;
```

This generates a compile-time error, saying that the leading 0 no longer means octal numbers. In Raku, all the radix prefixes are unified: `0b` for binary, `0x` for hexadecimal, and `0o` for octal representation.

{% include nav.html %}

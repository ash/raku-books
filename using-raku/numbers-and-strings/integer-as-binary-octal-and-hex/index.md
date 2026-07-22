---
title: 42. Integer as binary, octal, and hex
---

{% include menu.html %}

*Print a given integer number in the binary, octal, and hexadecimal representations.*

On an integer object, call the `base` method with the corresponding number:

```raku
say 42.base(2);  # 101010
say 42.base(8);  # 52
say 42.base(16); # 2A
```

Alternatively, use the `fmt` method, which is defined for integers and accepts the formatting string in the `printf` format:

```raku
my $int = 42;
say $int.fmt('Hex: %x'); # Hex: 2a
say $int.fmt('Oct: %o'); # Oct: 52
say $int.fmt('Bin: %b'); # Bin: 101010
```

There also exists a conventional function `printf`, which works similarly to how it behaves in other programming languages: It needs a formatting string and a list of values to be substituted to the `%`-placeholders.

```raku
my $int = 42;
printf("Hex: %x\n", $int); # Hex: 2a
printf("Oct: %o\n", $int); # Oct: 52
printf("Bin: %b\n", $int); # Bin: 101010
```

The above examples print the values without their radix prefixes. To add a prefix, use the `%#` forms:

```raku-static
printf("Hex: %#x\n", $int); # Hex: 0x2a
printf("Oct: %#o\n", $int); # Oct: 052 (not 0o52!)
printf("Bin: %#b\n", $int); # Bin: 0b101010
```

{% include nav.html %}

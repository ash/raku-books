---
title: Postfixes
---

{% include menu.html %}

Postfix operators are unary operators placed after their single operand.

`++` is a postfix increment. The change of the value happens after the current value is used in the expression.

```raku
my $x = 42;
say $x++; # 42
say $x;   # 43
```

`--` is a postfix decrement.

Both postfix and prefix operators magically know how to deal with numbers in filenames.

```raku
my $filename = 'file01.txt';
for 1..10 {
    say $filename++;
}
```

This example prints the list of the filenames with incrementing numbers: `file01.txt`, `file02.txt`, ... `file10.txt`.

{% include nav.html %}

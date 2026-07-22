---
title: Non-value argument passing
---

{% include menu.html %}

By default, you pass the arguments by their values. Despite that, it is not possible to modify them inside the sub. To pass a variable by reference, add the `is rw` trait. (Note that formally this is not a reference but a mutable argument.)

```raku
sub inc($x is rw) {
    $x++;
}

my $value = 42;
inc($value);
say $value; # 43
```

{% include nav.html %}

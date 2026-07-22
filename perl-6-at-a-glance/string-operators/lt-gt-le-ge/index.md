---
title: lt, gt, le, ge
---

{% include menu.html %}

`lt`, `gt`, `le`, and `ge` are the operators for comparing strings: less, more, less or equal, and more or equal. The operands are converted to the string values if necessary.

`leg` tells if is the two strings are equal or the left operand is less or greater than the second one. Its behaviour is similar to what `<=>` does for numbers or what the `cmp` built-in operator does in Perl 5. Like the `cmp` in Perl 6, the `leg` operator returns a value of the `Order` type.

```raku
say "a" leg "b";        # Less
say "abc" leg "b";      # Less
say "bc" leg "b";       # More
say "abc" leg "ABC".lc; # Same
```

Before the operation, the operands are converted to strings if necessary.

```raku
say 42 leg "+42"; # More
say 42 leg "42";  # Same
```

{% include nav.html %}

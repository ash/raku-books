---
title: 80. Increase digits by one
---

{% include menu.html %}

*In the given integer number, replace all the digits so that 1 becomes 2, 2 becomes 3, etc., and 9 becomes 0.*

This task can be approached both mathematically and string-wise. In Raku, regexes seem to be the best match. Although a number is an example of the numeric data type, the language allows seamless changes when you want to start working with them as with strings.

In the proposed solution, a number is matched against a regex.

```raku
my $number = 564378901;
$number ~~ s:g/ (\d) /{ ($0 + 1) % 10 }/;
say $number;
```

Similar to the code of Task 76, Double each character, a global replacement happens. The target is a digit, `\d`. (We ignore the fact that the `\d` character class matches 580 different characters in the Unicode space, see Task 39,

*Unicode digits.)*

So, a digit (treated as a character) lands in the `$0` variable. In the replacement part of `s///`, a block of code is placed. It takes the value of `$0` and adds `1` to it. As the `+` operator expects numeric operands, the character is converted to an integer and is incremented after it. The modulo operator keeps the value in the range between 0 and 9 (including), The new value is converted back to a string character, which replaces the original digit that was captured.

In the given example, `675489012` is printed.

Notice that it was not possible to use an increment operator in the replacement. An attempt to make it `$0++` would lead to an exception as the `++` operator needs a mutable object.

{% include nav.html %}

---
title: 5. Reverse a string
---

{% include menu.html %}

*Print a string in the reversed order from right to left.*

Strings, or the objects of the `Str` class, have the `flip` method, which does the work:

```raku
my $string = 'Hello, World!';
say $string.flip;
```

This code prints the desired result:

```
!dlroW ,olleH
```

The `flip` routine may be called both as a method on a string and as a standalone function:

```raku
say flip 'Abcdef'; # fedcbA
say 'Word'.flip;   # droW
```

Don’t forget that `say` can also be called as a method:

```raku
'Magic'.flip.say; # cigaM
```

There is also the `reverse` routine, but it cannot be applied directly to strings. It accepts lists, so a string first has to be converted to the list of characters, then reversed, and later joined again to a string.

Here is the code that works according to this description.

```raku
my $string = 'Hello, World!';
my $reversed = $string.split('').reverse().join('');
say $reversed; # !dlroW ,olleH
```

{% include nav.html %}

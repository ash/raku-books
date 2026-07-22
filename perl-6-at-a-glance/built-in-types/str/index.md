---
title: Str
---

{% include menu.html %}

`Str` is no doubt a string. In Perl 6, there are methods to manipulate strings. Again, you call them as methods on objects.

```raku
my $str = "My string";

say $str.lc; # my string
say $str.uc; # MY STRING

say $str.index('t'); # 4
```

Let us now get the length of a string. The naïve attempt to write `$str.length` produces an error message. However, a hint is also provided:

```raku-static
No such method 'length' for invocant of type 'Str'
Did you mean 'elems', 'chars', 'graphs' or 'codes'?
```

Thus, we have a simple and a mono-semantic method to get the length of a Unicode string.

```raku
say "περλ 6".chars; # 6
```

Getting used to the new way of working with strings as objects may take some time. For example, this how you can call the `printf` as a method on a string:

```raku-static
"Today is %02i %s %i\n".printf($day, $month, $year);
```

{% include nav.html %}

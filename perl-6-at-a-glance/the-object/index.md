---
title: The $/ object
---

{% include menu.html %}

As we have just seen, the smartmatch operator comparing a string with a regex returns an object of the `Match` type. This object is stored in the `$/` variable. It also contains all the matching substrings. To keep (catch) the substring a pair of parentheses is used. The first match is indexed as `0`, and you may access it as an array element either using the full syntax `$/[0]` or the shortened one: `$0`.

Remember that even the separate elements like `$0` or `$0` still contain objects of the `Match` type. To cast them to strings or numbers, coercion syntax can be used. For example, `~$0` converts the object to a string, and `+$0` converts it to an integer.

```raku
'Wed 15' ~~ /(\w+) \s (\d+)/;
say ~$0; # Wed
say +$1; # 15
```

{% include nav.html %}

---
title: What’s the date today?
---

{% include menu.html %}

Today, we’ll answer the question of what’s the date today.

So, to print the answer, you can use the following line of Raku code:

```raku
DateTime.now.yyyy-mm-dd.say
```

It looks transparent and prints the date in the format of YYYY-MM-DD. The good part is that the `DateTime` class is available straight ahead, and you don’t need to import any modules.

```
$ raku -e'DateTime.now.yyyy-mm-dd.say'
2019-10-17
```

As you have already seen in the previous chapters, calling the methods in a chain is a common practice in Raku. An alternative is to use `say` as a subroutine and use parentheses after the names of the methods:

```raku
say(DateTime.now().yyyy-mm-dd());
```

This code also works; it is completely correct, but it looks heavy.

What you should also notice and tell your friends, is that in Raku, you can use dashes and apostrophes in identifiers.

Well, maybe using apostrophes is not a great idea, but hyphens are used very widely already in the source code of Rakudo. Just make sure you put spaces around minus operator in arithmetical expressions to avoid any conflicts in parsing.

If you read documentation, you will find another method named in the same manner: `hh-mm-ss`. I bet you understand what it does.

```
> DateTime.now.hh-mm-ss.say
00:12:01
```

Notice that you will not find similar methods for different formats of the output, such as `dd-mm-yy` or `hh-mm`. Use the `formatter` instead. It is not a method, but an attribute defined in the `Datish` role. There is a default formatter in the `DateTime` class, but you may redefine it by providing the constructor with your own subroutine, for example:

```raku
DateTime.now(formatter => -> $dt {
    sprintf '%02d.%02d.%04d',
    $dt.day, $dt.month, $dt.year
}).say
```

A formatter here takes an anonymous subroutine (introduces by a thin arrow) with one argument `$dt`.

I hope this code prints the same date as in our initial one-liner, as you most likely read the whole section within one day.

{% include nav.html %}

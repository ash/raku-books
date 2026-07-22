---
title: 87. Current date and time
---

{% include menu.html %}

*Print current date and time as an epoch and in a human-readable format.*

The `time` function returns the current time as the Unix epoch:

```raku
say time;
```

The output is something like this: `1495785518`.

For manipulating dates and times, use the built-in `DateTime` class:

```raku
say DateTime.now;
```

The date is now in a more human-readable format, although still is overloaded with many details: `2017-05-26T10:02:20.500209+02:00`.

To access the separate elements of date and time, use the methods on the variable of the `DateTime` class:

```raku
my $dt = DateTime.now;

say $dt.day;    # 26
say $dt.month;  # 5
say $dt.year;   # 2017
say $dt.hour;   # 10
say $dt.minute; # 9
say $dt.second; # 5.55802702903748
```

The meaning of all the elements is quite straightforward.

All the values except seconds are integer. For the seconds, you may want to take the integer part only:

```raku-static
say $dt.second.Int;
```

{% include nav.html %}

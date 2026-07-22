---
title: 89. Datetime arithmetic
---

{% include menu.html %}

*Find the difference between the two dates. Add a given number of days to the date.*

The `DateTime` class defines the `+` and `–` operators, which can be used in combination with either another `DateTime` object or with the `Duration` object.

Let us first find the difference between the two given dates:

```raku
my $date1 = DateTime.new('2017-12-31T23:59:50');
my $date2 = DateTime.new('2018-01-01T00:00:10');

say $date2 - $date1; # 20
```

The type of the `$date2 - $date1` expression is `Duration`. In the numeric context, it returns the number of seconds. Therefore, there are 20 seconds between our dates at hand.

A `Duration` object can also be used instead of the second `DateTime` object.

For example, increase the given date by two minutes:

```raku
my $now = DateTime.now();
my $when = $now + Duration.new(120);
say "$now -> $when";
```

Or learn what were the date and time a week ago:

```raku-static
my $back = $now - Duration.new(3600 * 24 * 7);
say $back;
```

In the current design of the language, the constructor of the `Duration` class needs a number of seconds.

{% include nav.html %}

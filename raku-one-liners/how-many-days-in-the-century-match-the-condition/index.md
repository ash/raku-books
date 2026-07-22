---
title: How many days in the century match the condition?
---

{% include menu.html %}

Our next one-liner is quite long, and it would be better to write it in two lines, but it will show a very nice feature of Raku’s `Date` objects: they can be easily used in a range.

In essence, the task is to count Sundays between January 1, 1901 and December 31, 2000, and only count Sundays that fall on the first of the months.

The `Date` object in Raku implements the `succ` and `prec` methods, which are used to increment and decrement the date. It is also possible to use two dates as the boundaries of a range:

```raku
say (
    Date.new(year => 1901) ..^ Date.new(year => 2001)
).grep({.day == 1 && .day-of-week == 7}).elems
```

There are a few moments to comment here.

First, the two `Date` objects are created with a single named parameter, the `year`. This is possible because the signature of the constructor includes default values for both the month and the day:

```raku-static
multi method new(
    Date: Int:D() :$year!,
    Int:D() :$month = 1, Int:D() :$day = 1,
    :&formatter, *%_) {
   . . .
}
```

So, it’s easy to create a date for January 1, but you can’t do that for the last day of the year. But Perl 6 has a nice range operator `..^`, which excludes the right boundary and allows us to save quite a few characters (while we are not playing Raku Golf yet, that’s the topic of Chapter 7).

The longer version, with all explicit parts of the dates, would then look like this:

```raku
say (
    Date.new(year => 1901, month => 1, day => 1) ..
    Date.new(year => 2000, month => 12, day => 31)
).grep({.day == 1 && .day-of-week == 7}).elems
```

You create a range and grep its values using a combined condition. Remember that there is no need to explicitly type `$_` when you want to call a method on the default variable (or the topic variable as it is also called).

An alternative is using two `grep`s with a star:

```raku
say (
    Date.new(year => 1901, month => 1, day => 1) ..
    Date.new(year => 2000, month => 12, day => 31)
).grep(*.day == 1).grep(*.day-of-week == 7).elems
```

An exercise for you to make at home: Print the number of days left until

*the end of the current year.*

{% include nav.html %}

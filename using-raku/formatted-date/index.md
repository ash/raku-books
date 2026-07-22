---
title: 88. Formatted date
---

{% include menu.html %}

*Print the current date in an even better format.*

There is a built-in `DateTime` class. It is equipped with a few useful methods, so there’s no need to use external modules for many standard tasks. Save the current moment in the `$now` variable:

```raku-static
my $now = DateTime.now;
```

The easiest thing is to print the proper time using a dedicated method:

```raku-static
say $now.hh-mm-ss; # 22:37:16
```

To achieve a more granular control over both the date and time parts, use the `formatter` attribute of the constructor together with methods like `day` and `month` to get separate parts of the date and time (see Task 87, Current

*date and time):*

```raku
my $now = DateTime.now(
    formatter => {
        sprintf '%02d.%02d.%04d, %02d:%02d',
        .day, .month, .year, .hour, .minute
    }
);

say $now; # 14.10.2017, 22:41
```

The formatting string `'%02d.%02d.%04d, %02d:%02d'` uses the standard POSIX `printf` format. The `sprintf` function forms a string that is returned when a `DateTime` object (the `$now` variable, in our case) is stringified. For instance, it is used when the variable is interpolated in a string:

```raku-static
say "Current date and time: $now.";
```

{% include nav.html %}

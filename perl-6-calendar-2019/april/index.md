---
title: April
---

{% include menu.html %}

![Perl 6 Calendar 2019 — April](/assets/calendar/april.jpg){.cal-page}

**Implement the Sleep sort algorithm**

```raku-async
my @data = 5, 3, 1, 4, 2;
await gather for @data -> $d {
    take start {
        sleep $d;
        say $d;
    }
}
```

{% include nav.html %}

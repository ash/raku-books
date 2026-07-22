---
title: in and at
---

{% include menu.html %}

The other two factory methods, `Promise.in` and `Promise.at`, create a promise, which will be kept after a given number of seconds or by a given time. For example:

```raku-async
my $p = Promise.in(3);

for 1..5 {
    say $p.status;
    sleep 1;
}
```

```

```

The programme prints the following lines.

```
Planned
Planned
Planned
Kept
Kept
```

That means that the promise was kept after three seconds.

{% include nav.html %}

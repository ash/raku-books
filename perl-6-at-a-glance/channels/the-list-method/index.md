---
title: The list method
---

{% include menu.html %}

The `list` method accompanies the previously seen methods and returns everything that is left unread in the channel.

```raku-async
my $c = Channel.new;

$c.send(5);
$c.send(6);

$c.close;
say $c.list; # (5 6)
```

The method blocks the programme until the channel is open, thus it is wise to close it before calling the `list` method.

{% include nav.html %}

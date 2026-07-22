---
title: Read and write
---

{% include menu.html %}

In Perl 6, there is a predefined class `Channel`, which includes, among the others, the `send` and the `receive` methods. Here is the simplest example, where an integer number first is being sent to the channel `$c` and is then immediately read from it.

```

```

```raku-async
my $c = Channel.new;
$c.send(42);
say $c.receive; # 42
```

```

```

A channel can be passed to a sub as any other variable. Should you do that, you will be able to read from that channel in the sub.

```raku-async
my $ch = Channel.new;
$ch.send(2017);
func($ch);

sub func($ch) {
    say $ch.receive; # 2017
}
```

```

```

It is possible to send more than one value to a channel. Of course, you can later read them all one by one in the same order as they were sent.

```raku-async
my $channel = Channel.new;

# A few even numbers are sent to the channel.
for <1 3 5 7 9> {
    $channel.send($_);
}

# Now, we read the numbers until the channel has them.
# "while @a -> $x" creates a loop with the $x as a loop variable.
while $channel.poll -> $x {
    say $x;
}

# After the last available number, Nil is returned.
$channel.poll.say; # Nil
```

In the last example, instead of the previously used `receive` method, another one is used: `$channel.poll`. The difference lies in how they handle the end of the queue. When there are no more data in the channel, the `receive` will block the execution of the programme until new data arrive. Instead, the `poll` method returns `Nil` when no data are left.

To prevent the programme from hanging after the channel data is consumed, close the channel by calling the `close` method.

```raku-static
$channel.close;
while $channel.receive -> $x {
    say $x;
}
```

Now, you only read data, which are already in the channel, but after the queue is over, an exception will occur: `Cannot receive a message on a closed channel`. Thus either put a `try` block around it or use `poll`.

```raku-static
$channel.close;
try {
    while $channel.receive -> $x {
        say $x;
    }
}
```

Here, closing a channel is a required to quit after the last data piece from the channel arrives.

{% include nav.html %}

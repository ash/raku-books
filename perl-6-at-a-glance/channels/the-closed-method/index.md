---
title: The closed method
---

{% include menu.html %}

The `Channel` class also defines a method that checks on whether the channel is closed. This method is called `closed`.

```raku-async
my $c = Channel.new;
say "open" if !$c.closed; # is open

$c.close;
say "closed" if $c.closed; # closed
```

Despite the simplicity of using the method, it in fact returns not a simple Boolean value but a promise object (a variable of the `Promise` class). A promise (we will talk about this later) can be either kept or broken. Thus, if the channel is open, the `closed` promise is not yet kept; it is only given (or planned).

```
Promise.new(status => PromiseStatus::Planned, …)
```

After the channel is closed, the promise is kept.

```
Promise.new(status => PromiseStatus::Kept, …)
```

You can see the state of the promise above in its `status` field.

* * *

In this section, we discussed the simplest applications of channels, where things happen in the same thread. The big thing about channels is that they transparently do the right thing if you’re sending in one or more threads, and receiving in another one or more threads. No value will be received by more than one thread, and no value shall be lost because of race conditions when sending them from more than one thread.

{% include nav.html %}

---
title: Basics
---

{% include menu.html %}

The `Promise.new` constructor builds a new promise. The status of it can be read using the `status` method. Before any other actions are done with the promise, its status remains to be `Planned`.

```raku-async
my $p = Promise.new;
say $p.status; # Planned
```

```

```

When the promise is kept, call the `keep` method to update the status to the value of `Kept`.

```raku-async
my $p = Promise.new;
$p.keep;
say $p.status; # Kept
```

Alternatively, to break the promise, call the `break` method and set the status of the promise to `Broken`.

```raku-async
my $p = Promise.new;
say $p.status; # Planned

$p.break;
say $p.status; # Broken
```

```

```

Instead of asking for a status, the whole promise object can be converted to a Boolean value. There is the `Bool` method for that; alternatively, the unary operator `?` can be used instead.

```raku-static
say $p.Bool;
say ?$p;
```

Keep in mind that as a Boolean value can only take one of the two possible states, the result of the Boolean typecast is not a full replacement for the `status` method.

There is another method for getting a result called `result`. It returns truth if the promise has been kept.

```raku-async
my $p = Promise.new;
$p.keep;
say $p.result; # True
```

```

```

Be careful. If the promise is not kept at the moment the `result` is called, the programme will be blocked until the promise is not in the `Planned` status anymore.

In the case of the broken promise, the call of `result` throws an exception.

```raku-async
my $p = Promise.new;
$p.break;
say $p.result;
```

```

```

Run this programme and get the exception details in the console.

```
Tried to get the result of a broken Promise
```

```

```

To avoid quitting the programme under an exception, surround the code with the `try` block (but be ready to lose the result of `say`—it will not appear on the screen).

```raku-async
my $p = Promise.new;
$p.break;
try {
    say $p.result;
}
```

```

```

The `cause` method, when called instead of the `result`, will explain the details for the broken promise. The method cannot be called on the kept promise:

```
Can only call cause on a broken promise (status: Kept)
```

Like with exceptions, both kept and broken promises can be attributed to a message or an object. In this case, the `result` will return that message instead of a bare `True` or `False`.

This is how a message is passed for the kept promise:

```raku-async
my $p = Promise.new;
$p.keep('All done');
say $p.status; # Kept
say $p.result; # All done
```

This is how it works with the broken promise:

```raku-async
my $p = Promise.new;
$p.break('Timeout');
say $p.status; # Broken
say $p.cause;  # Timeout
```

{% include nav.html %}

---
title: anyof and allof
---

{% include menu.html %}

Another pair of factory methods, `Promise.anyof` and `Promise.allof`, creates new promises, which will be only kept when at least one of the promises (in the case of `anyof`) is kept or, in the case of `allof`, all of the promises listed at the moment of creation are kept.

One of the useful examples found in the documentation is a timeout keeper to prevent long calculations from hanging the programme.

Create the promise `$timeout`, which must be kept after a few seconds, and the code block, which will be running for longer time. Then, list them both in the constructor of `Promise.anyof`.

```raku-async
my $code = start {
    sleep 5
}
my $timeout = Promise.in(3);

my $done = Promise.anyof($code, $timeout);
say $done.result;
```

```

```

The code should be terminated after three seconds. At this moment, the `$timeout` promise is kept, and that makes the `$done` promise be kept, too.

The `then` method, when called on an already existing promise, creates another promise, whose code will be called after the “parent” promise is either kept or broken.

```raku-async
my $p = Promise.in(2);
my $t = $p.then({say "OK"}); # Prints this in two seconds

say "promised"; # Prints immediately
sleep 3;

say "done";
```

The code above produces the following output:

```

promised
OK
done
```

```

```

In another example, the promise is broken.

```raku-async
Promise.start({  # A new promise
    say 1 / 0    # generates an exception
                 # (the result of the division is used in say).
}).then({        # The code executed after the broken line.
    say "oops"
}).result        # This is required so that we wait until
                 # the result is known.
```

The only output here is the following:

```
oops
```

{% include nav.html %}

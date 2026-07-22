---
title: start
---

{% include menu.html %}

The `start` method creates a promise containing a block of code. There is an alternative way to create a promise by calling `Promise.start` via the `start` keyword.

```raku-async
my $p = start {
    42
}
```

(Note that in Perl 6, a semicolon is assumed after a closing brace at the end of a line.)

The `start` method returns a promise. It will be broken if the code block throws an exception. If there are no exceptions, the promise will be kept.

```raku-async
my $p = start {
    42
}
say $p.result; # 42
say $p.status; # Kept
```

```

```

Please note that the `start` instruction itself just creates a promise and the code from the code block will be executed on its own. The `start` method immediately returns, and the code block runs in parallel. A test of the promise status will depend on whether the code has been executed or not. Again, remember that `result` will block the execution until the promise is not in the `Planned` status anymore.

In the given example, the `result` method returns the value calculated in the code block. After that, the `status` call will print `Kept`.

If you change the last two lines in the example, the result may be different. To make the test more robust, add a delay within the code block.

```raku-async
my $p = start {
    sleep 1;
    42
}
say $p.status; # Planned
say $p.result; # 42
say $p.status; # Kept
```

```

```

Now, it can be clearly seen that the first call of `$p.status` is happening immediately after the promise has been created and informs us that the promise is `Planned`. Later, after the `result` unblocked the programme flow in about a second, the second call of `$p.status` prints `Kept`, which means that the execution of the code block is completed and no exceptions were thrown.

Would the code block generate an exception, the promise becomes broken.

```raku-async
my $p = start {
    die;
}
try {
    say $p.result;
}
say $p.status; # This line will be executed
               # and will print 'Broken'
```

```

```

The second thing you have to know when working with `start` is to understand what exactly causes an exception. For example, an attempt to divide by zero will only throw an exception when you try using the result of that division. The division itself is harmless. In Perl 6, this behaviour is called soft failure. Before the result is actually used, Perl 6 assumes that the result is of the `Rat` (rational) type.

```raku-async
# $p1 is Kept
my $p1 = start {
    my $inf = 1 / 0;
}

# $p2 is Broken
my $p2 = start {
    my $inf = 1 / 0;
    say $inf;
}

sleep 1; # Wait to make sure the code blocks are done

say $p1.status; # Kept
say $p2.status; # Broken
```

{% include nav.html %}

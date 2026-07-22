---
title: 91. Setting timeouts
---

{% include menu.html %}

*Do not wait for a slow code block if it takes too long.*

Promises are the best way to create timeouts. In the following example, two code blocks are created; they are executed in parallel.

```raku-async
my $timeout = Promise.in(2).then({
    say 'Timeout after 2 seconds';
});

my $code = start {
    sleep 5;

    say 'Done after 5 seconds';
}
```

Both `$timeout` and `$code` are the promises, i. e. objects of the `Promise` type. Actually, the `$timeout` variable is a promise that is executed as a result of keeping the anonymous promise created by the `Promise.in(2)` call. The `in` method of the `Promise` class creates a promise that becomes kept after the given number of seconds.

The second promise, stored in the `$code` variable, is created by the `start` function. This is a long-running code block, which does not return within five seconds. The `$code` promise can be kept only after that time.

The `$timeout` promise is kept earlier than the `$code` one. To let the program continue earlier, create another promise with the help of the `anyof` method:

```raku-static
await Promise.anyof($timeout, $code);

say 'All done';
```

The flow of the whole program is the following: first, the `$timeout` code block is created and starts running in a separate thread. Then, without waiting, the `$code` block has been created and launched. Finally, the next line of the main thread is executed; it creates an anonymous thread and waits until it is kept. The `await` routine blocks the execution of the main program until at least one of its arguments is kept. This program prints ‘`All` `done`’ after two seconds, and exits:

```
$ raku timeout.rk
Timeout after 2 seconds
All done
```

If the `$code` thread is completed first (say, if we changed the timeout value to 10 seconds), then the output is different, and the timeout is not triggered:

```
$ raku timeout.rk
Done after 5 seconds
All done
```

Keep in mind that in our examples, the program finishes after printing ‘`All` `done`’. In case the program continues after that, the longest promise will still be running.

For example, add a simple delay like the one shown below:

```raku-static
await Promise.anyof($timeout, $code);
say 'All done';
sleep 20;
```

In this case, the program prints all three messages:

```
$ raku timeout.rk
Timeout after 2 seconds
All done
Done after 5 seconds
```

{% include nav.html %}

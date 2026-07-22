---
title: 92. Sleep Sort
---

{% include menu.html %}

*Implement the Sleep Sort algorithm for a few small positive integer values.*

The Sleep Sort is a funny implementation of the sorting algorithm. For each input value, an asynchronous thread starts, which waits for the number of seconds equals to the input number and then prints it. So, if all the threads are spawned simultaneously, the output of the program contains the sorted list.

Here is the solution in Raku. On the next page, we will go through the bits of it and explain all the important moments.

```raku-local
await gather for @*ARGS -> $value {
    take start {
        sleep $value/10;
        say $value;
    }
}
```

Pass the values via the command line, and get them sorted.

```
$ raku sleep-sort.rk 9 10 2 8 5 7 6 4 1 3
```

```
. . .
```

The input values from the command line come to the `@*ARGS` array. The first step is to iterate over the array:

```raku-static
for @*ARGS -> $value {
     . . .
}
```

For each `$value`, the `start` block creates a promise with a code block that waits for the time that is proportional to the value and prints the value after that time.

```raku-static
start {
    sleep $value/10;
    say $value;
}
```

Dividing the value by ten speeds up the program. On the other hand, the delay should not be too small to avoid race conditions between different threads.

After a separate promise has been created for each input number, the program has to wait until all of them are kept. To achieve that, the `gather`— `take` construction is used. The `take` keyword adds another promise to a sequence, which is then returned as a whole by the `gather` keyword.

```raku-static
gather for @*ARGS -> $value {
    take start {
        . . .
    }
}
```

Finally, the `await` routine ensures the program does not quit until all the promises are kept or, in other words, until all the numbers are printed.

```raku-static
await gather . . . {
    take start {
        . . .
    }
}
```

{% include nav.html %}
